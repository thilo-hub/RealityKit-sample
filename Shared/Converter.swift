//
//  Converter.swift
//  test3ds
//
//  Created by Thilo Jeremias on 02.11.21.
//

import Foundation
import RealityKit

import os
 let logger = Logger(subsystem: "com.apple.sample.photogrammetry",
                            category: "HelloPhotogrammetry")

typealias Request = PhotogrammetrySession.Request

class Converter: ObservableObject {
    private var inputURL : URL?
    @Published var model: URL?
    @Published var detail: ViewDetails = .preview

    @Published var progressValue : Double?
    private var session : PhotogrammetrySession?
    
    @MainActor
    private func outputReady(request: PhotogrammetrySession.Request,
                              result: PhotogrammetrySession.Result) {
        
            switch result {
                case .modelFile(let url):
                    model = url
                default:
                    logger.warning("\tUnexpected result: \(String(describing: result))")
            }
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
                                    await self.outputReady(request: request,result: result)
                                    case .requestProgress(_, let fractionComplete):
                                        await self.progress(value: fractionComplete)
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
    
    
}

