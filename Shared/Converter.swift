//
//  Converter.swift
//  test3ds
//
//  Created by Thilo Jeremias on 02.11.21.
//

import Foundation
import RealityKit
import os
import SwiftUI
 let logger = Logger(subsystem: "com.apple.sample.photogrammetry",
                            category: "HelloPhotogrammetry")
//@MainActor
typealias Request = PhotogrammetrySession.Request

//enum ViewDetails: String, CaseIterable {
//    case preview
//    case reduced
//    case medium
//    case full
//    var det: Request.Detail {
//        switch self {
//        case .preview: return PhotogrammetrySession.Request.Detail.preview
//        case .reduced: return PhotogrammetrySession.Request.Detail.reduced
//        case .medium: return PhotogrammetrySession.Request.Detail.medium
//        case .full: return PhotogrammetrySession.Request.Detail.full
//    }
//        
//}

class Conv2: ObservableObject {
    private var inputURL : URL?
    @Published var model: URL?
    @Published var detail: ViewDetails = .preview
//    var session: PhotogrammetrySession?
    @Published var progressValue : Double?
    private var session : PhotogrammetrySession?
    //private typealias Request = PhotogrammetrySession.Request
    @MainActor
    private func outputReady(out: URL){
        model = out
    }
    @MainActor
    private func progress(value:Double){
        progressValue = value
    }
    init(){
        
    }

    var fileURL : URL? {
        get {
            return inputURL
        }
        set(newfile) {
                inputURL = newfile
                model = nil
                let outputFilename = "testing.usdz"
                let outputUrl = URL(fileURLWithPath: outputFilename)
         
                do {
                    session = try PhotogrammetrySession(input: inputURL!)
                    let detail: Request.Detail? = detail.det

                    let req = PhotogrammetrySession.Request.modelFile(url: outputUrl, detail: detail!)
                    try session!.process(requests: [req])
                    Task.detached() {
                        do {
                            for try await output in self.session!.outputs {
                                switch output {
                                    case .processingComplete:
                                        logger.log("Processing is complete!")
                                        
                                     case .requestError(let request, let error):
                                        print(error)
                                        logger.error("Request \(String(describing: request)) had an error: \(String(describing: error))")
                                       
                                    case .requestComplete(let request, let result):
        //                                self.fileURL = outputUrl
                                        await self.outputReady(out: outputUrl)
                                        print(result)
                                      case .requestProgress(let request, let fractionComplete):
        //                                self.progressValue = fractionComplete
                                          await self.progress(value: fractionComplete)
        //                            ContentView.handleRequestProgress(request: request,fractionComplete: fractionComplete)
        //                                print(fractionComplete)
                                    case .inputComplete:  // data ingestion only!
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
                } catch {
                    print("Failed")
                    return
                }

                  
            
            }
        }
    
//= nil
//    func run(input: URL, detail: ViewDetails)
    
}

struct Converter {
    
    var fileURL : URL? // = Bundle.main.url(forResource: "MyScene.scnassets/Data5", withExtension: "usdz")!
    //URL(bundle:"/Users/thilo/Documents/xcode/test3ds/Shared/MyScene.scnassets/Data5.usdz")
    var maybeSession: PhotogrammetrySession? = nil
    var output :URL? = nil
    private var outputUrl = URL(fileURLWithPath: "output.usdz") // fileURLWithPath: outputFilename)
    var progressValue : Double = 0.0
    var detail: Request.Detail? = .preview


    func run(inputFolderUrl : URL) {
        var maybeSession: PhotogrammetrySession? = nil
        do {
            maybeSession = try PhotogrammetrySession(input: inputFolderUrl
            )
            logger.log("Successfully created session.")
        } catch {
            logger.error("Error creating session: \(String(describing: error))")
        }
        guard let session = maybeSession else {
            Foundation.exit(1)
        }
        
        let waiter = Task {
            do {
                for try await output in session.outputs {
                    switch output {
                        case .processingComplete:
                            logger.log("Processing is complete!")
                         case .requestError(let request, let error):
                            print(error)
                            logger.error("Request \(String(describing: request)) had an error: \(String(describing: error))")
                           
                        case .requestComplete(let request, let result):
                            print(result)
                          case .requestProgress(let request, let fractionComplete):
                            print(fractionComplete)
                        case .inputComplete:  // data ingestion only!
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
