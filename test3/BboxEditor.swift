//
//  ContentView.swift
//  test1
//
//  Created by Thilo Jeremias on 04.11.21.
//

import SwiftUI
import SceneKit

//
// Minimal view that allows a mesh (the first one) to be shown with its bounding box
// Sliders allow to adjust the box
//

struct GlobeView: View {

    @State var myscene: SCNScene
    @State var pos = SCNVector3(0,0,0)
    @State var scale = 1.0
 
    // Create scene from base scene with correct bounding box installed
    var scene: SCNScene {
        let s = myscene
        
        let bbx = s.rootNode.childNode(withName: "MyBounding", recursively: true)!
            bbx.position = pos
            bbx.scale = SCNVector3(scale,scale,scale)
        return s

    }
 
    var body: some View {
        VStack{
            HStack {
                Text("Good")
                Slider(value: $scale,in: 0...10)
                Text(String(format:"R: %2.3f",scale)).frame(minWidth: 80,alignment: .topTrailing)
                Slider(value: $pos.x, in:-1 ... 1)
                Slider(value: $pos.y, in:-1 ... 1)
                Slider(value: $pos.z, in:-1 ... 1)
            }
            SceneView(
                scene: scene,
                    options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                    ]
            )
        }
    }
}

struct ContinousResizingOkView: View {
    let scene: SCNScene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
     
    var fullScene: SCNScene {
        let s = scene
        let rebBoxNode: SCNNode
        if let element = s.rootNode.childNodes.first {
             rebBoxNode = makeBBox(element)
             rebBoxNode.name = "MyBounding"
            s.rootNode.addChildNode(rebBoxNode)
        }
        else
        {
            let redBox = SCNBox(width: 0.1 , height: 0.1,
                                  length: 0.1, chamferRadius: 0.005)
            redBox.firstMaterial?.diffuse.contents = CGColor(red: 0.8, green: 0.0, blue: 0, alpha: 0.8)
            rebBoxNode = SCNNode(geometry: redBox)
        }
        return s
    }

    var body: some View {
        GlobeView(myscene: fullScene)
  }
}


struct ContinousResizingOk_Previews: PreviewProvider {
    @State static var scene: SCNScene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
   
    
    static var previews: some View {
        GlobeView(myscene: scene)
    }
}


