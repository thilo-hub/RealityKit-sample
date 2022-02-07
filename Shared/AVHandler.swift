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

enum frameBufferState {
    case empty
    case filling
    case loaded
    case folder
}
//func convertCIImageToCVPixelBuffer(from image: CIImage) -> CVPixelBuffer? {
//    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
//    var pixelBuffer : CVPixelBuffer?
//    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.extent.width), Int(image.extent.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
//
//    guard (status == kCVReturnSuccess) else {
//        return nil
//    }
//
//    return pixelBuffer
//}
enum PhotogrammetryFramesErrors: Error {
    case isADirectory
}
// Itterator for movie files
class PhotogrammetryFrames : ObservableObject, IteratorProtocol, Sequence, Equatable  {
    static func == (lhs: PhotogrammetryFrames, rhs: PhotogrammetryFrames) -> Bool {
        return false
//        return lhs.trackReaderOutput == rhs.trackReaderOutput // fixme
    }
    var url: URL?
    @Published var state: frameBufferState = .empty
    @Published var count: Int = 0
    private var trackReaderOutput: AVAssetReaderTrackOutput?
    var skip: Int = 0
    private var skipStart: Int = 0
    private var maxFrames: Int = 1000
//    private var thumbidx: Int = 0
//    var wanted: [Bool]?
    @Published var thumbnails: [ImageFrame]=[]
    
    init(fileURL:URL, skip: Int = 0,start: Int = 0,maxFrames: Int = 1000, disableFolders: Bool) throws {
        url = fileURL
        if CFURLHasDirectoryPath(fileURL as CFURL) {
            let fm = FileManager.default
            let items = try fm.contentsOfDirectory(at: fileURL, includingPropertiesForKeys: [])
            var imid:Int = 1
            trackReaderOutput = nil
            
            for item in items.sorted(by: {$0.absoluteString < $1.absoluteString}){
                
                if let ciimage = CIImage(contentsOf: item) {
                    let nimage = ciimage.asNSImage(pixelsSize: nil, repSize: nil)!
                    let pb = nimage.pixelBuffer()!
                    var sample = PhotogrammetrySample(id:imid, image: pb )
                    sample.metadata = readEXIF(file: item)!
                    
                    let size: CGSize = CGSize(width: 120, height: 100)
                    let thumbnail =  ciimage.asNSImage(pixelsSize: size, repSize: size)!
                    
                    

                    thumbnails.append(ImageFrame(id: imid, thumbnail: thumbnail, image: sample, isenabled: true))

                    print("Found \(item)")
                    imid += 1
                }
                }
           
            self.maxFrames = imid
            self.count = 0
            state = .folder
//            if !disableFolders {
//                self.state = .loaded
////                throw PhotogrammetryFramesErrors.isADirectory
//            }
 
            
        } else {
            count = 0
            state = .filling
            thumbnails = []
//            }
        }
        
    }
//    func reset() {
//        let tr: CMTimeRange = .zero
//        let start: [NSValue] = [tr as NSValue]
//
//        trackReaderOutput.reset(forReadingTimeRanges: start)
//    }
    func samples() -> [PhotogrammetrySample] {
        let rv = self.thumbnails.filter({$0.isenabled}).map({$0.image})
            return rv
    }
    func next() -> PhotogrammetrySample? {
        
        var getCountFrames = skip
        if state == .folder {
//            throw PhotogrammetryFramesErrors.isADirectory
            return nil
        }
        if state == .filling && thumbnails.isEmpty{
            let asset = AVURLAsset(url: url!)
            let reader = try? AVAssetReader(asset: asset)
            let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
            let frames = Int(asset.duration.seconds * Double(videoTrack.nominalFrameRate));
            self.skip = frames < 100 ? 0 : frames / 100 ;
            self.maxFrames = frames
            
            // read video frames as BGRA
            trackReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings:[String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)])
//            if let tro = trackReaderOutput {
                
                reader!.add(trackReaderOutput!)
                reader!.startReading()

            
            
            getCountFrames = skipStart
//            state = .filling
        } else if state == .loaded {
            if self.count < thumbnails.count {
                let ri = thumbnails[self.count]
                self.count += 1
                return ri.image
            }
            self.count = 0
            return nil
            
        }
        // Skip as needed
        while getCountFrames > 0 {
             getCountFrames -= 1
             trackReaderOutput?.copyNextSampleBuffer()
        }
        if let sampleBuffer = trackReaderOutput?.copyNextSampleBuffer() {
            count += 1
            let imid = count
            if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let sample = PhotogrammetrySample(id:imid, image: imageBuffer )
                let cii = CIImage(cvImageBuffer: imageBuffer)
                if let cgim = cii.asCGImage() {// convertCIImageToCGImage(cii) {
                    let size: CGSize = CGSize(width: 120, height: 100)
                    let thumbnail = NSImage(cgImage: cgim, size: size)
                    thumbnails.append(ImageFrame(id: imid, thumbnail: thumbnail, image: sample, isenabled: true))
                }
                
                return sample
            }
            
        }
       state = .loaded
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
