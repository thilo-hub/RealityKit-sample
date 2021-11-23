import Foundation


import SwiftUI
import AVKit
import RealityKit

// Itterator for movie files
struct PhotogrammetryFrames : IteratorProtocol, Sequence  {
    
    
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



