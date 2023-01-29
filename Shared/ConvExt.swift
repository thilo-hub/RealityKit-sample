//
//  ConvExt.swift
//  RealityKit-Sample (macOS)
//
//  Created by Thilo Jeremias on 06.02.22.
//

import Foundation
import AVKit

extension NSImage {

    func pixelBuffer() -> CVPixelBuffer? {
        let width = self.size.width
        let height = self.size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {return nil}
        
       // context.translateBy(x: 0, y: height)
       // context.scaleBy(x: 1.0, y: -1.0)
        
        let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicsContext
        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        NSGraphicsContext.restoreGraphicsState()
        
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return resultPixelBuffer
    }
    func depthPixelBuffer() -> CVPixelBuffer? {
        let width = self.size.width
        let height = self.size.height
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_DepthFloat32,
                                         attrs,
                                         &pixelBuffer)
        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)

//        let linearGraySpace = CGColorSpace(name: CGColorSpace.linearGray)
        let linearGraySpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 32,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: linearGraySpace,
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue | CGBitmapInfo.floatComponents.rawValue)
        else {
            return nil
        }
        
        let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicsContext
        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        NSGraphicsContext.restoreGraphicsState()
        
        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return resultPixelBuffer
    }
}

extension CIImage {
   /// Create a CGImage version of this image
   ///
   /// - Returns: Converted image, or nil
   func asCGImage(context: CIContext? = nil) -> CGImage? {
      let ctx = context ?? CIContext(options: nil)
      return ctx.createCGImage(self, from: self.extent)
   }

   /// Create an NSImage version of this image
   /// - Parameters:
   ///   - pixelSize: The number of pixels in the result image. For a retina image (for example), pixelSize is double repSize
   ///   - repSize: The number of points in the result image
   /// - Returns: Converted image, or nil
   #if os(macOS)
   @available(macOS 10, *)
   func asNSImage(pixelsSize: CGSize? = nil, repSize: CGSize? = nil) -> NSImage? {
      let rep = NSCIImageRep(ciImage: self)
      if let ps = pixelsSize {
         rep.pixelsWide = Int(ps.width)
         rep.pixelsHigh = Int(ps.height)
      }
      if let rs = repSize {
         rep.size = rs
      }
      let updateImage = NSImage(size: rep.size)
      updateImage.addRepresentation(rep)
      return updateImage
   }
   #endif
}

extension CGImage {
   /// Create a CIImage version of this image
   ///
   /// - Returns: Converted image, or nil
   func asCIImage() -> CIImage {
      return CIImage(cgImage: self)
   }

   /// Create an NSImage version of this image
   ///
   /// - Returns: Converted image, or nil
   func asNSImage() -> NSImage? {
      return NSImage(cgImage: self, size: .zero)
   }
    
    /// Create an CVPixelBuffer version of this image
    ///
    /// - Returns: Converted image, or nil
    func asCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.width), Int(self.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        if let pixelBuffer {
            let ci=CIImage(cgImage: self)
            let ig = CIContext()
            ig.render(ci, to: pixelBuffer)
        }
        
        return pixelBuffer
    }

}
