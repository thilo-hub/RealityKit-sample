//
//  Converter.swift
//  test3ds
//
//  Created by Thilo Jeremias on 02.11.21.
//

import Foundation
import RealityKit
import AVKit

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
    let outputUrl = URL(fileURLWithPath: "outputModel.usdz")
    
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
 
    fileprivate func sessionHandler() -> Task<(), Never> {
        return Task.detached() {
            do {
                for try await output in self.session!.outputs {
                    switch output {
                    case .processingComplete:
                        logger.log("Processing is complete!")
                    case .requestError(let request, let error):
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
    }
    var input : URL? {
        get {
            return inputURL
        }
    set(folder) {
        inputURL = folder
        model = nil
        do {
            // If I would only know how to tell file/folder from URL...
            do {
                // Try Movie first
                let frames = try PhotogrammetryFrames(fileURL: inputURL!)
                session = try PhotogrammetrySession(input: frames)
            } catch {
                // Lets hope its a directory
                session = try PhotogrammetrySession(input: inputURL!)
            }
            let detail: Request.Detail? = detail.det

            let req = PhotogrammetrySession.Request.modelFile(url: outputUrl, detail: detail!)
            try session!.process(requests: [req])
            _ = sessionHandler()
        } catch {
            print("Failed")
            return
        }

          
    
        }
    }

    
    
}

// Itterator for movie files
struct PhotogrammetryFrames : IteratorProtocol, Sequence  {
    
    typealias Element = PhotogrammetrySample
    
    var imgs: [PhotogrammetrySample] = []
    var count: Int
    let trackReaderOutput: AVAssetReaderTrackOutput
    init(fileURL:URL) throws {
        let asset = AVURLAsset(url: fileURL)
        let reader = try AVAssetReader(asset: asset)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]

        // read video frames as BGRA
        trackReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings:[String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)])
        count = 0
        reader.add(trackReaderOutput)
        reader.startReading()
    }
    mutating func next() -> PhotogrammetrySample? {
        if let sampleBuffer = trackReaderOutput.copyNextSampleBuffer() {
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            count += 1

//            let count = sampleBuffer!.decodeTimeStamp
             let sample = PhotogrammetrySample(id:count, image: imageBuffer! )
            return sample
        }
        
       return nil
    }
}


