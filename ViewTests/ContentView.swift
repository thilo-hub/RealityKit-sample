//
//  ContentView.swift
//  ViewTests
//
//  Created by Thilo Jeremias on 15.11.21.
//

import SwiftUI
import SceneKit

fileprivate func createScene() -> SCNScene {
    let sc = SCNScene(named:"MyScene.scnassets/Arrows.dae")!

    let camn = SCNNode()
    let cam  = SCNCamera()
    camn.camera = cam
    camn.position = SCNVector3(0,0,40)
    sc.rootNode.addChildNode(camn)

    
    let plane  = SCNPlane(width: 20,height: 20)
    plane.materials[0].diffuse.contents = CGColor(red: 0, green: 0, blue: 1, alpha: 0.5)
    plane.materials[0].isDoubleSided = true

    let planen = SCNNode(geometry: plane)
    planen.position = SCNVector3(0,0,0)
    planen.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Angle(degrees:-90).radians)
    sc.rootNode.addChildNode(planen)
    
    let box  = SCNBox(width: 5, height: 7, length: 9, chamferRadius: 0.5)
    let boxn = SCNNode(geometry: box)
    boxn.name = "box"
    sc.rootNode.addChildNode(boxn)

    return sc
}

struct ContentView: View {
    @State var scnview = SCNView()
    var scene: SCNScene = createScene()
    
    var exclusiveGesture: some Gesture {
        ExclusiveGesture(drag, magnify)
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                let box = scene.rootNode.childNode(withName: "box", recursively: false)!
                let t = value.translation
                
                let dir = simd_float3(0.01,0.01,0)

                let s: Float = Float(t.width)
                let min  = simd_float3(box.boundingBox.min)
                let max = simd_float3(box.boundingBox.max)
                let P = (min+s*max)
                  
                box.position = SCNVector3(P * dir) // P.y,P.z)
                box.scale = SCNVector3( ((s-1) * dir) + 1)
                
//                box.position.x = CGFloat(position.x) //A[0][0])
//                box.scale.x = CGFloat(A[0][0]) // scale.x)
            

            }
            .onEnded { value in
      
    //            updateOrientation(of: modcam ? cam : target)
            }
    }
    @GestureState var magnifyBy = CGFloat(1.0)
    var magnify: some Gesture {
        MagnificationGesture()
            .onChanged{ (value) in
     
             }
            .onEnded{ value in
             }
    }

    
    
    
    
    
    
    var body: some View {
         HStack{
            
            // Make a scene per camera
            ForEach( scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil}), id:\.self)  { n in
            
            SceneViewX (
                sview: $scnview,
                scene: scene,
                pointOfView: n,
                options: [
//                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                    ]
                )
                .gesture(exclusiveGesture)

            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
