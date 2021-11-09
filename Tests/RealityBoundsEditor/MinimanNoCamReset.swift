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
    
    @Binding var boxnode: SCNNode
    @Binding var myscene: SCNScene
    
    var body: some View {
        HStack{
            Text("Good Cam")
            Text(label)
            Slider(value: $inv, in: 0.5 ... 4) { value in
                print(inv)
                boxnode.scale = SCNVector3(x:inv,y:inv,z:inv)
            }
            Button("X"){
                print("X")
                let bx = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.2)
                let nd = SCNNode(geometry: bx)
                myscene.rootNode.addChildNode(nd)
            }
            .onAppear(perform: {
                print("Appearing")
            })
                
            Text("\(inv)")
        }
    }
}

struct SuperView: View {
    @Binding var scene: SCNScene
    @Binding var rot: Double
    @Binding var boxnode: SCNNode
    @Binding var cam: SCNNode
    
    var cameraNode: SCNNode? {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0 , y: 0, z: 3)
        cameraNode.camera?.zNear = 0.1
        return cameraNode
    }
    

    var body: some View {
        VStack {
            ControlerView(label:"Rotate:",inv: $rot,boxnode: $boxnode, myscene: $scene)
//            DragGestureView()
            SceneView(
                scene: scene,
                pointOfView: cam,
                options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                ]
            )
        }
    }
}
struct CamNotResetView: View {
    @State var scene: SCNScene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
    @State var rotVec: Double = 1.0
    @State var redBoxNode: SCNNode
    @State var cam: Binding<SCNNode>
    var boxnode: SCNNode {
        
        let ball = SCNBox(width: 0.1 , height: 0.1,
                              length: 0.1, chamferRadius: 0.005)
        ball.firstMaterial?.diffuse.contents = CGColor(red: 0.8, green: 0.0, blue: 0, alpha: 0.8)
        let scnnode = SCNNode(geometry: ball)
        
        let rc = SCNVector4Make(1,1,0,rotVec)
        scnnode.rotation = rc
        
          return scnnode
       

    }
    var arrowNode: SCNNode {
//        let arrow = SCN
        let arrow = SCNCylinder(radius: 0.1, height: 2)
        
        let nd = SCNNode(geometry: arrow)
        
        return nd
    }

    init(mycam: Binding<SCNNode>) {
 //        let redBox = SCNBox(width: 0.1 , height: 0.1,
//                              length: 0.1, chamferRadius: 0.005)
//        redBox.firstMaterial?.diffuse.contents = CGColor(red: 0.8, green: 0.0, blue: 0, alpha: 0.8)
//        redBoxNode = SCNNode(geometry: redBox)
//
//        redBoxNode = arrowNode
        let arrow = SCNCylinder(radius: 0.01, height: 0.1)
        let arrowhead = SCNCone(topRadius: 0, bottomRadius: 0.5, height: 2)
        let arrowheadN = SCNNode(geometry: arrowhead)
//        arrowheadN.scale = SCNVector3(0.1,0.1,0.1)
        arrowheadN.position = SCNVector3(0,2,0)
        let nd = SCNNode(geometry: arrow)
        nd.addChildNode(arrowheadN)
        redBoxNode = nd
        cam = mycam

        let s = scene.rootNode

        s.addChildNode(redBoxNode)
        
    }
    var body: some View {
        SuperView(scene: $scene, rot: $rotVec, boxnode: $redBoxNode, cam: cam)
    }
}

#if false
struct CamNotResetView_Previews: PreviewProvider {
    
    static var previews: some View {
        CamNotResetView()
    }
}
#endif

