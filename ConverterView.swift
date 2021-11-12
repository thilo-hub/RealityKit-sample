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
    @ObservedObject var images: AllImages = AllImages()
    
    
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
            } else if let furl = converter.input {
                if converter.session != nil {
                VStack {
                    HStack{
                        Button("Reload") { converter.input = furl}
                        Text("Input ready: \(furl)")
                        Stepper(value: $converter.skip,
                                in: 0...10,
                                step: 1) {
                            Text("Skip: \(converter.skip)  ")
                        }
                                .onAppear(perform: {images.fileURL = furl })

                    }
                    MovieViewer(Movie: images, toggle: true)
                    
                }
                }

            } else {
                Text("Please select a directory or movie to convert")
            }
         
    }
}


