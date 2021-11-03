//
//  File.swift
//  test3ds
//
//  Created by Thilo Jeremias on 03.11.21.
//
import SwiftUI
import SceneKit


struct ConverterView: View {
    @ObservedObject var converter: Converter
    
    
    var scene: SCNScene? {
        if let fileURL = converter.model {
            return try? SCNScene(url: fileURL)
        }
        return nil
        
            
    }
 
    var cameraNode: SCNNode? {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        cameraNode.camera?.zNear = 0.1
        return cameraNode
    }
 
    var body: some View {
        VStack {
        if let s = scene {
            Text("Here")
            SceneView(
                scene: s,
                pointOfView: cameraNode,
                options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                ]
            )
                
            } else if let f = converter.progressValue {
                ProgressView(value: f)
            } else {
                Text("Please select a directory to convert")
            }
        }
        Spacer()
        
    }
}
