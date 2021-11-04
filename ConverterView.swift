//
//  File.swift
//  test3ds
//
//  Created by Thilo Jeremias on 03.11.21.
//
import SwiftUI
import SceneKit
import RealityKit

struct ConverterView: View {
    @ObservedObject var converter: Converter
    
    var scene: SCNScene? {
        if let m = converter.model {
            return try? SCNScene(url: m)
        }
        return nil
    }
        
    var body: some View {
        if let s = scene {
            BoundBoxEditorView(myscene: s,boundingBox: $converter.bBox)
            } else if let f = converter.progressValue {
                ProgressView(value: f)
            } else {
                Text("Please select a directory or movie to convert")
            }
         
    }
}


