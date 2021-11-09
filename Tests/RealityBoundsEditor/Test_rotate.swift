//
//  Test_rotate.swift
//  test3
//
//  Created by Thilo Jeremias on 06.11.21.
//

import SwiftUI
import SceneKit

struct ControlerView: View {
    @State var label: String
    @State var inv2: Float = 1.0
    @Binding var inv: Double
    @Binding var scene: SCNScene?
    @State var boxnode: SCNNode = SCNNode()
    @State var scale: SCNVector3 = SCNVector3(1,1,1)
    @State var nscale: simd_float3 = SIMD3(1,1,1)
//    var nscale: simd_float3  {
//        return SIMD3(1,1,1)
//    }



    var body: some View {
        HStack{
            Text(label)
            Slider(value: $nscale.x, in: 0.5 ... 4)
            Slider(value: $inv, in: 0.5 ... 4) { value in
//                print(value)
                boxnode.scale = SCNVector3(x:inv,y:inv,z:inv)
                let inv2 = Float(inv)
                nscale = SIMD3(inv2,inv2,inv2)
                self.inv2 = inv2
            }
                
            Text("\(inv)")
            Button("+"){
                if let rn = scene?.rootNode {
                    if let ch = rn.childNodes.first {
                        let bb = makeBBox(ch:ch)
                        bb.simdScale = nscale;
                    rn.addChildNode(bb)
                    }
                }
            }
            Button("HalfOK"){
                if let rn = scene?.rootNode {
                    let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.01)
//                    let node = SCNNode(geometry: box)
                    boxnode.geometry = box
//                    boxnode.scale = SCNVector3(x:inv,y:inv,z:inv)
                    boxnode.scale = scale
                    rn.addChildNode(boxnode)
                }
            }
        }
    }
}
struct ContentView: View {
    @State var scene: SCNScene? = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
    
    var body: some View {
        
        SuperView(scene: $scene)
    }
}
struct SuperView: View {
    @State var rot: Double = 0
    @State var campos = SCNVector3(x: 0 , y: 0, z: 3)
    @Binding var scene: SCNScene?
    var cameraNode: SCNNode? {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = campos
        cameraNode.camera?.zNear = 0.1
        return cameraNode
    }

    var body: some View {
        VStack {
            ControlerView(label:"Rotate:",inv: $rot,scene: $scene)
            Text("Cam: \(cameraNode!.position.x)")
            SceneView(
                scene: scene,
                pointOfView: cameraNode,
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

