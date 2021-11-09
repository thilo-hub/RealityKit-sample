//
//  ContentView.swift
//  test1
//
//  Created by Thilo Jeremias on 04.11.21.
//

import SwiftUI
import SceneKit
import RealityKit

fileprivate func mkCam() -> SCNNode {
    
    let cameraNode = SCNNode()
    
    cameraNode.camera = SCNCamera()
//        pos = pos ??
    cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
    cameraNode.camera?.zNear = 0.1
    
    return cameraNode

}

fileprivate func mkScene() -> SCNScene? {
    if let s = SCNScene(named: "MyScene.scnassets/Data5.usdz") {
        
//        s.rootNode.addChildNode(mkBbox(refnode: s.rootNode.childNodes.first!))
        return s
    }
    return nil
}
//
//fileprivate func mkBbox(refnode: SCNNode) -> SCNNode {
//    let scale = SCNVector3Make(turn,turn,turn)
//    let position = SCNVector3Make(rot, 0, 0)
//    let scnnode = makeBBox(ch: refnode)
//    scnnode.scale = scale
//    scnnode.position = position
//    return scnnode
//}

//struct SubView: View {
//    @State var turn: Double = 1.0
//    @State var rot: Double = 1.0
//    @State var scene: SCNScene
//    @State var cameraNode: SCNNode?
//
////    @State var cameraNode: SCNNode
//
//    var body: some View {
//
//    }
//
//}
//struct GlobeView: View {
//    @Binding var turn: Double
//    @Binding var rot: Double
//    @State var cameraNode: SCNNode?
////    @Binding var cameraNode: SCNNode
//
//
//
//    var bbox: SCNNode? {
//        return nil
//    }
//
//    var scene: SCNScene? {
//        return mkScene()
//        }
//
////    @State var pos: SCNVector = SCNVector
//
//     var body: some View {
//      VStack{
//        HStack {
//            Text("R:\(turn)")
//            Button("X"){
//               print("Nothing")
//            }
//        }
//          SubView(scene: scene!,cameraNode: mkCam())
//
//
//      }
//  }
//}


struct ContentView: View {
    @State var turn:Double = 2.5
    @State var rot: Double = 0
    @State var cam: SCNNode = mkCam()
//    @State  var cam:SCNNode? = getcam()
//  var cameraNode: SCNNode? { mkCam() }
    var scene : SCNScene? {
        if let s =  mkScene() {
            
            if let n = s.rootNode.childNodes.first {
            
            let bx = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.01)
            bx.materials.first?.diffuse.contents = CGColor(red: 0, green: 0.5, blue: 0, alpha: 0.7)
            let nd = SCNNode(geometry: bx)
            nd.name = "BX"
            n.addChildNode(nd)
//
//                  let scale = SCNVector3Make(turn,turn,turn)
//                let position = SCNVector3Make(rot, 0, 0)
//                let scnnode = makeBBox(ch: refnode)
//                scnnode.scale = scale
//                scnnode.position = position
//                return scnnode
//            }
//
//            let pvec = SCNVector3Make(turn, rot, 0.0)
//        n.position = pvec
            
        }
        return s;
        }
        return nil
    }
    @State var pos: SIMD3<Float>?
  var body: some View {
    return VStack {
//    Image(systemName: "circle")
//      .foregroundColor(Color.blue)
//      .onTapGesture {
//        withAnimation(.linear(duration: 36)) {
//          self.turn = 720
//        }
//      }
//        GlobeView(turn: $turn,rot: $rot, cameraNode: cam)
        
            HStack {
            Slider(value: $turn,in: 0...40)
            Slider(value: $rot,in: 0...40)
                Button("X"){
                    
                    if let n=scene?.rootNode.childNode(withName: "BX", recursively: true) {
                       
                            n.position = SCNVector3  (Float(turn),Float(rot),0)
                       
                    }
                }
            }
            SceneView(
                scene: scene,
                pointOfView: mkCam(),
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

