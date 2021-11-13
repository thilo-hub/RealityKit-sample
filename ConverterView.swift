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
             } else
            {
                 HStack {
                 if let f = converter.progressValue {
                    ProgressView(value: f)
                }
                 if converter.state != .empty {
                     Button("Kill Session"){converter.killSession()}
                 }
                 }
                 if converter.state == .loaded {
                VStack {
                    HStack{
                        if  let furl = converter.input  {
                        Button("Reload") { converter.input = furl}
                        Text("Input ready: \(furl)")
                        }
                        Stepper(value: $converter.skip,
                                in: 0...10,
                                step: 1) {
                            Text("Skip: \(converter.skip)  ")
                        }
//                                .onAppear(perform: {
//                                    images.movie = $converter.frames
                                    
//                                })

                    }
                    
                    if converter.images.count > 0{
                        MovieViewer(Movie: converter, toggle: true)
                    }
                    
    
                
                }

            }
                 else {
                     Text("Please select a directory or movie to convert")
                 }
            }
         
    }
}


