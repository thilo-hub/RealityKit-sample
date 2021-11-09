//
//  ContentView.swift
//  CamTest
//
//  Created by Thilo Jeremias on 08.11.21.
//

import SwiftUI
import SceneKit

class theCam {
    var cam: SCNNode
    var scene: SCNScene
//    var subview: SCNView
    
    init() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0 , y: 0, z: 3)
        cameraNode.camera?.zNear = 0.1
        cam = cameraNode
        scene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
        
        let vc = SCNView()
        let scene1 = SCNScene(named: "MyScene.scnassets/Arrows.dae")!
        vc.scene = scene1
//        vc.addSubview()
//        NSHostingController(root)
//    }

    }
}

struct ContentView: View {
    var scene: SCNScene {
        let s = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
        return s
    }
    @State var cam = theCam()

    var body: some View {
        VStack {
            Button("X"){
                print(cam.cam.position)
                let s = SCNScene(named: "MyScene.scnassets/Arrows.dae")!
                cam.scene = s
//                print(scene.)
            }
            SceneView(
                scene: cam.scene,
                pointOfView: cam.cam,
                    options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                    ]
            )
            SceneView(
                scene: cam.scene,
                pointOfView: cam.cam,
                    options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                    ]
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
