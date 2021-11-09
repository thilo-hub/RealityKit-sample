//
//  Converter.swift
//  test3ds
//
//  Created by Thilo Jeremias on 02.11.21.
//

import Foundation
import RealityKit
import AVKit
import SceneKit

import os

let logger = Logger(subsystem: "com.apple.sample.photogrammetry",
                            category: "HelloPhotogrammetry")

typealias Request = PhotogrammetrySession.Request

class Converter: ObservableObject {
    // if a progress value is published you can use it
    @Published var progressValue : Double?

    // if a model is published you can view it
    @Published var olddetail: ViewDetails = .preview
    @Published private var results: [ViewDetails:URL] = [:]

    private var inputURL : URL?
    private var defaulturl: URL?
    var boundingBox: Request.Geometry?
    var bBox: BoundingBox?
    private var session : PhotogrammetrySession?

    var model: URL? {
        get {
            return results[olddetail]
        }
        set(newurl){
            defaulturl = newurl
            
        }
    }

    var outURL: URL {
        let file = "outputModel-" + olddetail.rawValue.capitalized + ".usdz"
        return URL(fileURLWithPath: file)
    }
    
    
     // Changing the view details relies on an existing session
    // if the view is available and the bounding box did not change
    
    var detail: ViewDetails  {
        get {
            return olddetail
        }
        set(newdetail) {
            // Do we have results already
            olddetail = newdetail
            if results[newdetail] == nil {
                if let s = session {
                    let det = newdetail.det
                    if let bBox = bBox {
                        boundingBox?.bounds.min = bBox.min
                        boundingBox?.bounds.max = bBox.max
                        print(det,outURL)
                    }
                    let req = PhotogrammetrySession.Request.modelFile(url: outURL, detail: det,geometry: boundingBox)
                    try? s.process(requests: [req])
                }
            }
        }
    }

    // Start conversion when file update
    var input : URL? {
        get {
            return inputURL
        }
        set(folder) {
            if folder != inputURL {
                inputURL = folder
                 results = [:]
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
                    let oreq = PhotogrammetrySession.Request.bounds
                    let req = PhotogrammetrySession.Request.modelFile(url: outURL, detail: detail!)
                    try session!.process(requests: [req,oreq])
                    _ = sessionHandler()
                } catch {
                    print("Failed")
                    return
                }
            }
            
            }
    }
       
    @MainActor
    private func outputReady(request: PhotogrammetrySession.Request,
                              result: PhotogrammetrySession.Result) {
        
            switch result {
                case .modelFile(let url):
                    results[olddetail] = url
                    progressValue = nil
                case .bounds(let box):
                    print("Got a box: \(box)")
                    boundingBox = Request.Geometry(bounds:box)
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
}

// Itterator for movie files
struct PhotogrammetryFrames : IteratorProtocol, Sequence  {
    
    typealias Element = PhotogrammetrySample
    
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


