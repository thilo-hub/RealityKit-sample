//
//  Converter_new.swift
//  RealityKit-Sample
//
//  Created by Thilo Jeremias on 06.02.22.
//

import Foundation
import RealityKit
import SwiftUI


typealias MyDetail = ViewDetails?

enum ViewDetails: String, CaseIterable {
    case preview
    case reduced
    case medium
    case full
    var det: Request.Detail {
        switch self {
        case .preview: return PhotogrammetrySession.Request.Detail.preview
        case .reduced: return PhotogrammetrySession.Request.Detail.reduced
        case .medium: return PhotogrammetrySession.Request.Detail.medium
        case .full: return PhotogrammetrySession.Request.Detail.full
        }
    }
        
}

typealias Request = PhotogrammetrySession.Request
typealias Element = PhotogrammetrySample


enum ConverterState {
    case empty   // Nothing loaded
    case ready   // Session running, file loaded
    case digesting  // Request running
//    case loaded   // Request finished model available
}


class Converter: ObservableObject {
//    @EnvironmentObject var robj: rObject
    @Published var state: ConverterState = .empty
    @Published var progressValue : Double?
    @Published var model: Binding<URL?>
    @Published var results: [ViewDetails:URL] = [:]
    @Published var boundingBoxEnabled: Bool = false
    @Published var messages:Binding<String>
    
    private  var SessionHandler :  Task<(), Never>?
    
    private var session : PhotogrammetrySession?
//    @Published var sessionConfig = PhotogrammetrySession.Configuration()
    var sessionConfig: PhotogrammetrySession.Configuration?
    private var inputProvider: Binding<PhotogrammetryFrames?>?
    

    var boundingBox: Request.Geometry?

    init(input provider: Binding<PhotogrammetryFrames?> ,sessionConfig: PhotogrammetrySession.Configuration, messages:Binding<String>,model: Binding<URL?>) {
        self.sessionConfig = sessionConfig
        self.model = model
        inputProvider = provider
        self.messages = messages
        if state == .empty && provider.wrappedValue != nil {
                createSession(input: provider.wrappedValue!)
        }
    }
    private func killSession() {
        if let s = session {
            s.cancel()
        }
        session = nil
        state = .empty
        progressValue = nil
    }
    
    func cancelRequest() {
        state = .ready
    }
    var outURL: URL {
        let file: String
        if let dname = detail?.rawValue.capitalized {
            file = "outputModel-" + dname + ".usdz"
        } else {
            file = "Session.not.Initialized.usdz"
        }
        return URL(fileURLWithPath: file)
    }

    // Changing the view details relies on an existing session
    // if the view is available and the bounding box did not change
       
    @Published  var detail: ViewDetails? {
       willSet(newvalue) {
           if newvalue != nil && newvalue != detail {
               results[newvalue!] = nil
               model.wrappedValue = nil
           }
           if let dtl = newvalue {
               if let res = results[dtl]  {
                   model.wrappedValue = res
               } else {
                   model.wrappedValue = nil
                   if session != nil {
                       
                       let det = dtl.det
//                       if let bBox = bBox {
//                           // TODO: Add rotation / translation to boundingbox
//                           boundingBox?.bounds.min = bBox.min
//                           boundingBox?.bounds.max = bBox.max
//                           print(det,outURL)
//                       }
                       let req = PhotogrammetrySession.Request.modelFile(url: outURL, detail: det,geometry: boundingBox)
                       
                       try! session?.process(requests: [req])
                       self.state = .digesting
                       print("Request started")
                   }
               }
           }
         }
   }
     
    
    
    
    private func createSession(input: PhotogrammetryFrames){
        // Grab enabled frames and use as input
        
        do {
            if input.state == .folder {
                session = try PhotogrammetrySession(input: input.url!, configuration: sessionConfig!)
            } else if input.state == .filling {
                // We  have a movie which is not yet fully
                session = try PhotogrammetrySession(input: input, configuration:  sessionConfig!)
            } else {
                    // process cached frame list
                let selectionList = input.samples()
                    session = try PhotogrammetrySession(input: selectionList,configuration: sessionConfig!)
                
            }
            state = .ready
            SessionHandler = sessionHandler()
        } catch {
                print("Error")
        }
    }
    
    
    @MainActor private func addMessage(message: String){
        self.messages.wrappedValue += message + "\n"
    }
    @MainActor
    private func outputReady(request: PhotogrammetrySession.Request,
                              result: PhotogrammetrySession.Result) {
        self.state = .ready
        progressValue = nil
            switch result {
                case .modelFile(let url):
                      print("Model done \(url)")
                    results[detail!] = url
                    model.wrappedValue = url
                    
                case .bounds(let box):
                    print("Got a box: \(box)")
                    self.boundingBox = Request.Geometry(bounds:box)
                default:
                    logger.warning("\tUnexpected result: \(String(describing: result))")
            }
    }

    @MainActor
    private func progress(value:Double? = nil,state: ConverterState? = nil){
        progressValue = value
        if let s = state {
            self.state = s
        }
    }

    fileprivate func sessionHandler() -> Task<(), Never> {
        return Task.detached() {
            do {
                for try await output in self.session!.outputs {
                    switch output {
                    case .processingComplete:
                        logger.log("Processing is complete!")
                        await self.addMessage(message: "Complete")
                        await self.progress(state: .ready)
                    case .requestError(let request, let error):
                        await self.addMessage(message: String(describing: error))

                        logger.error("Request \(String(describing: request)) had an error: \(String(describing: error))")
                    case .requestComplete(let request, let result):
                        await self.addMessage(message: "Request End")

                        await self.outputReady(request: request,result: result)
                    case .requestProgress(_, let fractionComplete):
                        await self.progress(value: fractionComplete)
                    case .inputComplete:  // data ingestion only!
//                        await self.inputDone()
                        await self.addMessage(message: "Input done")

                        logger.log("Data ingestion is complete.  Beginning processing...")
                    case .invalidSample(let id, let reason):
                        await self.addMessage(message: "Invalid Sample! id=\(id)  reason=\"\(reason)\"")

                        logger.warning("Invalid Sample! id=\(id)  reason=\"\(reason)\"")
                    case .skippedSample(let id):
                        await self.addMessage(message: "Sample id=\(id) was skipped by processing.")

                        logger.warning("Sample id=\(id) was skipped by processing.")
                    case .automaticDownsampling:
                        await self.addMessage(message: "Downsampling")
                        logger.warning("Automatic downsampling was applied!")
                    case .processingCancelled:
                        await self.progress(state: .ready)
                      await self.addMessage(message: "Cancel")
                        logger.warning("Processing was cancelled.")
                    @unknown default:
                        logger.error("Output: unhandled message: \(output.localizedDescription)")
                        
                    }
                    
                }
            } catch {
                logger.error("Output: ERROR = \(String(describing: error))")
                Foundation.exit(0)
            }
        }
    }
}



