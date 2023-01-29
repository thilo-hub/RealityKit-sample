//
//  AVHandler.swift
//  RealityKit-Sample (iOS)
//
//  Created by Thilo Jeremias on 10.11.21.
//

//TODO:  Create new window for model view and keep file view window

import SwiftUI
import AVKit
import RealityKit


// individual frame
struct ImageFrame: Identifiable {
    var id:Int
    var thumbnail: NSImage
    var image: PhotogrammetrySample
    var isEnabled: Bool = true
    var isHidden: Bool = false
    var mask: CGRect? = nil
}

enum PhotogrammetryFramesErrors: Error {
    case isADirectory
}

class PhotogrammetryFrames : ObservableObject, IteratorProtocol, Sequence  {
    var url: URL?
    @Published var thumbnails: [ImageFrame] = []
    var maxFrames: Int
    // State of the frambuffer cache
    enum frameBufferState {
        case empty       // fresh
        case filling     // Movie assigned but not processed
        case loaded      // Movie loaded and individual frames available
        case folder      // Skip internal processing and let the API handle the folder
    }
    @Published var state: frameBufferState = .empty
    var frameListChanged = true
    @Published var first: Int = 0 {
        didSet { setSkipped() }
    }
    @Published var last: Int = 0 {
        didSet { setSkipped() }
    }
    
    func setSkipped() {
        for i in 0..<thumbnails.count {
            let fi = i // thumbnails[i].id
            thumbnails[i].isEnabled =
                fi >= first && fi <= last && fi % (skip+1) == 0
        }
        frameListChanged = true
    }
    
    @Published var skip: Int {
        didSet { setSkipped() }
    }
    
    
    fileprivate func loadDirectory(_ fileURL: URL) throws -> Int  {
        let fm = FileManager.default
        let items = try fm.contentsOfDirectory(at: fileURL, includingPropertiesForKeys: [])
        var imid:Int = 1
        // making photogrametry samples from an image is not yet done
        // just use the folder as an input and capture thumbnails
        // filter...  to be done later...
        for item in items.sorted(by: {$0.absoluteString < $1.absoluteString}){
            
            if let ciimage = CIImage(contentsOf: item) {
                let nimage = ciimage.asNSImage(pixelsSize: nil, repSize: nil)!
                let pb = nimage.pixelBuffer()!
                var sample = PhotogrammetrySample(id:imid, image: pb )
                sample.metadata = readEXIF(file: item)!
                
                let size: CGSize = CGSize(width: 120, height: 100)
                let thumbnail = ciimage.asNSImage(pixelsSize: size, repSize: size)!
                
                let frame = ImageFrame(id: imid, thumbnail: thumbnail, image: sample, isEnabled: true )
                
                DispatchQueue.main.async {
                    self.thumbnails.append(frame)
                }
                
                print("Found \(item)")
                imid += 1
            }
        }
        return imid
    }
    
    fileprivate func loadMovie(_ fileURL: URL, _ maxFrames: Int) async -> Int {
        // Movie
        
        let asset = AVAsset(url: fileURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.requestedTimeToleranceAfter = CMTime.zero
        imageGenerator.requestedTimeToleranceBefore = CMTime.zero
        
        let last: Int
        if let tracks = try? await asset.load(.tracks),
           let frameRate = try? await tracks[0].load(.minFrameDuration),
           let duration = try? await asset.load(.duration)
        {
            let countFrames = duration.value / frameRate.value
            last = Int(countFrames)
            let loadFrames = Swift.min( Int64(maxFrames) , countFrames )
            let increment =  duration.value / loadFrames
            
            let rn:[CMTime] = Array(0...countFrames).map({t in CMTime(value: t*increment, timescale: duration.timescale)})
            
            
            let imageGeneratorImages = imageGenerator.images(for: rn)
            for await img in imageGeneratorImages {
                switch img {
                case .success(_,let img,let tm):
                    let imid:Int = Int(tm.value/20)
                    let size: CGSize = CGSize(width: 120, height: 100)
                    let thumbnail = NSImage(cgImage: img, size: size)
//                    let sample = PhotogrammetrySample(id:imid, image: self.getCVPixb(from: img)! )
                    let sample = PhotogrammetrySample(id:imid, image: img.asCVPixelBuffer()!)
                    
                    
                    DispatchQueue.main.async {
                        self.thumbnails.append(ImageFrame(id: imid, thumbnail: thumbnail, image: sample, isEnabled: true))
                    }
                    break
                case .failure(let tm, let err):
                    print("Bad \(tm) \(err)")
                    break
                }
            }
        } else {
            last = 0
        }
        return last
    }
    
    init(fileURL:URL, skip: Int = 0,start: Int = 0,maxFrames: Int = 100) async throws {
        self.skip = skip
        url = fileURL
        self.maxFrames = maxFrames
        let items: Int
        if CFURLHasDirectoryPath(fileURL as CFURL) {
            items = try loadDirectory(fileURL)  // I guess maxFrames is ignored ....
            self.state = .folder
        } else {
            items = await loadMovie(fileURL, maxFrames)
            self.state = .filling
        }
        self.last = items
        self.maxFrames = Swift.min(items,maxFrames)
    }
    
    private var idx:Int = 0
    func next() -> PhotogrammetrySample? {
        while (idx < thumbnails.count) {
            let th = thumbnails[idx]
            idx += 1
            if th.isEnabled {
                return th.image
            }
        }
        idx = 0;
        return nil
    }
  
    func samples() -> [PhotogrammetrySample] {
        let rv = self.thumbnails.filter({$0.isEnabled}).map({$0.image})
        print("Return filtered \(rv.count) images")
            return rv
    }
}
