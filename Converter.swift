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

class Converter: ObservableObject {
    // if a progress value is published you can use it
    @Published var progressValue : Double?
    @Published var skip: Int = 0
    
    @Published var frames: PhotogrammetryFrames?
    @Published var state: digested = .empty
    // if a model is published you can view it
    
    @Published private var results: [ViewDetails:URL] = [:]

    
    private var defaulturl: URL?
    var boundingBox: Request.Geometry?
    var bBox: BoundingBox?
    
    private  var session : PhotogrammetrySession?
    private  var SessionHandler :  Task<(), Never>?
    
    @Published var images: [ImageFrame] = []
    
    func killSession() {
        session = nil
        SessionHandler = nil
    }
    
    var model: URL? {
        get {
            if let detail = detail {
                return results[detail]
            }
            return nil
        }
        set(newurl){
            defaulturl = newurl
            
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
  
            if loadedFile != input &&  session != nil {
                session = nil
                SessionHandler = nil
                images = []
                frames = nil
            }
            
            let imagelist = images.filter({$0.isenabled}).map({$0.image})
            do {
               
                if  !imagelist.isEmpty {
                    session = try PhotogrammetrySession(input: imagelist)
                } else {
                    frames = try PhotogrammetryFrames(fileURL: input!, skip: skip)
                    session = try PhotogrammetrySession(input: frames!)

                }
            } catch {
                do {
                    session = try PhotogrammetrySession(input: input!)
                } catch {
                    print("Error")
                }
            }
 
            loadedFile = input
            self.state = .digesting
        
            // Do an initial bounds request?
            let oreq = PhotogrammetrySession.Request.bounds
            do {
                try session!.process(requests: [oreq])
            } catch {
                print ("Error")
            }
            SessionHandler = sessionHandler()
        
            if session != nil {
                print("Session created")
            }

       }
    }
     // Changing the view details relies on an existing session
    // if the view is available and the bounding box did not change
    
    @Published var detail: ViewDetails? {
        
        didSet {
            if let dtl = detail {
                if results[dtl] == nil {
                    
                    if session != nil {
                        
                        let det = dtl.det
                        if let bBox = bBox {
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
    
    
    @MainActor
    private func inputDone() {
        self.state = .loaded
        self.images = self.frames?.thumbnails ?? []
    }
    @MainActor
    private func outputReady(request: PhotogrammetrySession.Request,
                              result: PhotogrammetrySession.Result) {
        
            switch result {
                case .modelFile(let url):
                    results[detail!] = url
                    progressValue = nil
                case .bounds(let box):
                    print("Got a box: \(box)")
                    boundingBox = Request.Geometry(bounds:box)
                default:
                    logger.warning("\tUnexpected result: \(String(describing: result))")
            }
    }

    @MainActor
    private func progress(value:Double?){
        progressValue = value
    }
 
    fileprivate func sessionHandler() -> Task<(), Never> {
        return Task.detached() {
            do {
                for try await output in self.session!.outputs {
                    switch output {
                    case .processingComplete:
                        logger.log("Processing is complete!")
                        await self.progress(value: nil)
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

