//
//  exifData.swift
//  RealityKit-Sample (macOS)
//
//  Created by Thilo Jeremias on 06.02.22.
//

import ImageIO
import Foundation

func readEXIF(file: URL) -> [ String: Any ]? {
    print(file)
    var dict:[ String: Any ] = [:]
    if let imageSource = CGImageSourceCreateWithURL(file as CFURL, nil) {
        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
        dict = (imageProperties as? [String: Any])!
        let w = dict["PixelWidth"]
        let h = dict["PixelHeight"]
        dict["PixelWidth"] = h
        dict["PixelHeight"] = w
        dict["Depth"] = nil
        //dict["{Exif}"]["PixelXDimension"] = h
        //dict["{Exif}"]["PixelYDimension"] = w
        //print(dict)
        return dict
    }
    return [:]
}

