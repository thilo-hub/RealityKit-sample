//
//  Converter.swift
//  test3ds
//
//  Created by Thilo Jeremias on 02.11.21.
//

import Foundation
import RealityKit

typealias Request = PhotogrammetrySession.Request
typealias Element = PhotogrammetrySample

enum ConverterState {
    case empty   // Nothing loaded
    case ready   // Session running, file loaded
    case digesting  // Request running
//    case loaded   // Request finished model available
}


class Converter: ObservableObject {
    // if a progress value is published you can use it
    @Published var progressValue : Double?
    var skip: Int = 0
    @Published var state: ConverterState = .empty

    @Published var thumbnails: [ImageFrame] = []

    // if a model is published you can view it
    
    @Published private var results: [ViewDetails:URL] = [:]

    
    private var frames: PhotogrammetryFrames?

    @Published var sessionConfig = PhotogrammetrySession.Configuration()
    private var defaulturl: URL?
    var boundingBox: Request.Geometry?
    var bBox: BoundingBox?
    
    @Published  var session : PhotogrammetrySession?
    private  var SessionHandler :  Task<(), Never>?
    
    func cancelRequest() {
        if let s = session {
            s.cancel()
         }

    }
    func killSession() {
        if let s = session {
            s.cancel()
        }
        session = nil
//        SessionHandler = nil
        results = [:]
        progressValue = nil
        state = .empty
    }
    @Published var model: URL?
    
// Changing the view details relies on an existing session
// if the view is available and the bounding box did not change
   
   @Published var detail: ViewDetails? {
       willSet(newvalue) {
           if newvalue != nil && newvalue != detail {
               results[newvalue!] = nil
               model = nil
           }
           if let dtl = newvalue {
               if let res = results[dtl]  {
                   model = res
               } else {
                   model = nil
                   if session != nil {
                       
                       let det = dtl.det
                       if let bBox = bBox {
                           // TODO: Add rotation / translation to boundingbox
                           boundingBox?.bounds.min = bBox.min
                           boundingBox?.bounds.max = bBox.max
                           print(det,outURL)
                       }
                       let req = PhotogrammetrySession.Request.modelFile(url: outURL, detail: det,geometry: boundingBox)
                       try? session?.process(requests: [req])
                       print("Request started")
                   }
               }
           }
         }
   }
 
    var outURL: URL {
        let file: String
        if let dname = detail?.rawValue.capitalized {
            file = "outputModel-" + dname + ".usdz"
        } else {
            file = "Session.not.Initialized"
        }
        return URL(fileURLWithPath: file)
    }
    
    // Create converter session on input file
    private var loadedFile: URL?
    var input: URL? {
        get {
            if let s = session {
                if s.isProcessing {
                    return nil
                }
            return loadedFile
            }
            return nil
        }
        set(input){
            results = [:]
            model = nil
            detail = nil
  
            if loadedFile != input {
                
//            }&&  session != nil {
                session = nil
                SessionHandler = nil
                thumbnails = []
                frames = nil
                bBox = nil
            }
            
            // Grab enabled frames and use as input
            let selectionList = thumbnails.filter({$0.isenabled}).map({$0.image})
            do {
               
                if  !selectionList.isEmpty {
                    session = try PhotogrammetrySession(input: selectionList,configuration: sessionConfig)
                } else {
                    frames = try PhotogrammetryFrames(fileURL: input!, skip: skip)
                    session = try PhotogrammetrySession(input: frames!,configuration: sessionConfig)

                }
            } catch {
                do {
                    session = try PhotogrammetrySession(input: input!,configuration: sessionConfig)
                } catch {
                    print("Error")
                }
            }
 
            loadedFile = input
            self.state = .digesting
            if bBox == nil {
                // Do an initial bounds request?
                let oreq = PhotogrammetrySession.Request.bounds
                do {
                    try session!.process(requests: [oreq])
                } catch {
                    print ("Error")
                }
            }
//            if SessionHandler == nil {
                SessionHandler = sessionHandler()
//            }
        
            if session != nil {
                print("Session created")
            }

       }
    }
   
    // Processor
    @MainActor
    private func inputDone() {
        self.state = .ready
        if let frames = self.frames {
            self.thumbnails = frames.thumbnails  
            self.frames = nil
        }
    }
    @MainActor
    private func outputReady(request: PhotogrammetrySession.Request,
                              result: PhotogrammetrySession.Result) {
        
            switch result {
                case .modelFile(let url):
                    results[detail!] = url
                    model = url
                    progressValue = nil
                case .bounds(let box):
                    print("Got a box: \(box)")
                    boundingBox = Request.Geometry(bounds:box)
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
                        await self.progress(state: .ready)
                    case .requestError(let request, let error):
                        logger.error("Request \(String(describing: request)) had an error: \(String(describing: error))")
                    case .requestComplete(let request, let result):
                        await self.outputReady(request: request,result: result)
                    case .requestProgress(_, let fractionComplete):
                        await self.progress(value: fractionComplete)
                    case .inputComplete:  // data ingestion only!
                        await self.inputDone()
                        logger.log("Data ingestion is complete.  Beginning processing...")
                    case .invalidSample(let id, let reason):
                        logger.warning("Invalid Sample! id=\(id)  reason=\"\(reason)\"")
                    case .skippedSample(let id):
                        logger.warning("Sample id=\(id) was skipped by processing.")
                    case .automaticDownsampling:
                        logger.warning("Automatic downsampling was applied!")
                    case .processingCancelled:
                        await self.progress(state: .ready)
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

