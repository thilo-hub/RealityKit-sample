//
//  AVHandler.swift
//  RealityKit-Sample (iOS)
//
//  Created by Thilo Jeremias on 10.11.21.
//

import SwiftUI
import AVKit
import RealityKit

struct ImageFrame: Identifiable {
    var id:Int
    var thumbnail: NSImage
    var image: PhotogrammetrySample
    var isenabled: Bool = true
}

// Itterator for movie files
class PhotogrammetryFrames : IteratorProtocol, Sequence  {
    private var state: ConverterState = .empty
    @Published var count: Int = 0
    private let trackReaderOutput: AVAssetReaderTrackOutput
    private var skip: Int = 0
    private var skipStart: Int = 0
    private var maxFrames: Int = 1000
//    private var thumbidx: Int = 0
//    var wanted: [Bool]?
    @Published var thumbnails: [ImageFrame]=[]
    
    init(fileURL:URL, skip: Int = 0,start: Int = 0,maxFrames: Int = 1000) throws {
        let asset = AVURLAsset(url: fileURL)
        let reader = try AVAssetReader(asset: asset)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        self.skip = skip
        self.maxFrames = maxFrames
        thumbnails = []
        // read video frames as BGRA
        trackReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings:[String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)])
        count = 0
        reader.add(trackReaderOutput)
        reader.startReading()
    
    }
//    func reset() {
//        let tr: CMTimeRange = .zero
//        let start: [NSValue] = [tr as NSValue]
//
//        trackReaderOutput.reset(forReadingTimeRanges: start)
//    }
    func next() -> PhotogrammetrySample? {
        
        var getCountFrames = skip
        if state == .empty {
            getCountFrames = skipStart
            state = .digesting
        }
        // Skip as needed
        while getCountFrames > 0 {
             getCountFrames -= 1
             trackReaderOutput.copyNextSampleBuffer()
        }
        if let sampleBuffer = trackReaderOutput.copyNextSampleBuffer() {
            count += 1
            let imid = count
            if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let sample = PhotogrammetrySample(id:imid, image: imageBuffer )
                let cii = CIImage(cvImageBuffer: imageBuffer)
                if let cgim = convertCIImageToCGImage(cii) {
                    let size: CGSize = CGSize(width: 120, height: 100)
                    let thumbnail = NSImage(cgImage: cgim, size: size)
                    thumbnails.append(ImageFrame(id: imid, thumbnail: thumbnail, image: sample, isenabled: true))
                }
                
                return sample
            }
            
        }
       state = .ready
       return nil
    }
//    func getImage() -> ImageFrame? {
//            if thumbidx < count {
//                thumbidx += 1
//                return thumbnails[thumbidx]
//            }
//            return nil;
//    }

}
