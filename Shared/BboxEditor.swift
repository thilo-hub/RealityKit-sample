//
//  ContentView.swift
//  test1
//
//  Created by Thilo Jeremias on 04.11.21.
//

import SwiftUI
import SceneKit
import AppKit
import SpriteKit
import RealityKit

fileprivate func addEditorTools(s: SCNScene)  {
    
    let redBoundingBox: SCNNode
    
    if let top = s.rootNode.childNodes.first {
        top.name = "toi"
    }
    
    if let element = s.rootNode.childNodes.first {
        if  s.rootNode.childNode(withName: "MyBounding", recursively: false) != nil{
            return
        }else{
                   
            let topleft: SCNVector3 = element.boundingBox.max
             redBoundingBox = makeBBox(element)
             redBoundingBox.name = "MyBounding"
            s.rootNode.addChildNode(redBoundingBox)
            
            
            // Add arrows scaled  to scene
            let ar_a = SCNScene(named: "MyScene.scnassets/Arrows.dae")!
            let ar1 = ar_a.rootNode
            let bb = ar1.boundingBox
            let bw = 0.1 / (simd_float3(bb.max) - simd_float3(bb.min))

            ar1.scale = SCNVector3(bw)
            ar1.position = topleft
            s.rootNode.addChildNode(ar1)
          }
    }
}

class MySceneView: SCNScene {
    override init() {
         super.init()
        let model = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
        let arrow = SCNScene(named: "MyScene.scnassets/Arrows.dae")!
        let bbox  = makeBBox(model.rootNode)
        self.rootNode.addChildNode(model.rootNode)
        self.rootNode.addChildNode(arrow.rootNode)
        self.rootNode.addChildNode(bbox)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//
//    var sscene: SCNScene
//    init(model: SCNScene ){
//        SceneView(
//            scene: scene,
//                options: [
//                .allowsCameraControl,
//                .autoenablesDefaultLighting,
//                .temporalAntialiasingEnabled
//                ]
//            )
//        scene = model
//    }
}
struct BoundBoxEditorView: View {

    @State var myscene: SCNScene
    @State var pos = SCNVector3(0,0,0)
    @State var scale = 1.0
    @State var topRight = SCNVector3(1,1,1)
    @State var bottomLeft = SCNVector3(0,0,0)

    var scene: SCNScene {
        let s = myscene
        addEditorTools(s: s)
 
        let bbx = s.rootNode.childNode(withName: "MyBounding", recursively: false)!
            bbx.position = bottomLeft
            bbx.scale = topRight
        return s

    }
     
    var body: some View {
        VStack{
            HStack {
                Slider(value: $topRight.x, in:0 ... 2).background(.red)
                Slider(value: $topRight.y, in:0 ... 2).background(.green)
                Slider(value: $topRight.z, in:0 ... 2).background(.blue)
            }
            HStack {
                Slider(value: $bottomLeft.x, in:-1 ... 1).background(.red)
                Slider(value: $bottomLeft.y, in:-1 ... 1).background(.green)
                Slider(value: $bottomLeft.z, in:-1 ... 1).background(.blue)
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

struct BoundingView: View {
    let scene: SCNScene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
    
    var body: some View {
        BoundBoxEditorView(myscene: scene)
  }
}


struct ContinousResizingOk_Previews: PreviewProvider {
    @State static var scene: SCNScene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
    
    static var previews: some View {
        BoundBoxEditorView(myscene: scene)
    }
}


