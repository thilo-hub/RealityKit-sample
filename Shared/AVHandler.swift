//
//  AVHandler.swift
//  RealityKit-Sample (iOS)
//
//  Created by Thilo Jeremias on 10.11.21.
//

import SwiftUI
import AVKit
import RealityKit

// Itterator for movie files
struct PhotogrammetryFrames : IteratorProtocol, Sequence  {
    
    
    var count: Int
    let trackReaderOutput: AVAssetReaderTrackOutput
    var skip: Int = 0
    var maxFrames: Int = 1000
    
    init(fileURL:URL, skip: Int = 0,start: Int = 0,maxFrames: Int = 1000) throws {
        let asset = AVURLAsset(url: fileURL)
        let reader = try AVAssetReader(asset: asset)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        self.skip = skip
        self.maxFrames = maxFrames
        
        // read video frames as BGRA
        trackReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings:[String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)])
        count = 0
        reader.add(trackReaderOutput)
        reader.startReading()
    }
    func reset() {
        let tr: CMTimeRange = .zero
        let start: [NSValue] = [tr as NSValue]
    
        trackReaderOutput.reset(forReadingTimeRanges: start)
    }
    mutating func next() -> PhotogrammetrySample? {
        
       
            if let sampleBuffer = trackReaderOutput.copyNextSampleBuffer() {
                let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            count += 1
                let imid=count
                for _ in  0 ..< skip {
                    if trackReaderOutput.copyNextSampleBuffer() != nil {
                        count += 1
                    }
                  }
//            let count = sampleBuffer!.decodeTimeStamp
             let sample = PhotogrammetrySample(id:imid, image: imageBuffer! )
            return sample 
        }
        
       return nil
    }
}


