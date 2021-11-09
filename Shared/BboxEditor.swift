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
            ar1.name = "arrow"
//            redBoundingBox.addChildNode(ar1)
            s.rootNode.addChildNode(ar1)
          }
    }
}


struct BoundBoxEditorView: View {

    @State var myscene: SCNScene
    @State var scale = SCNVector3(1,1,1)
    @State var center = SCNVector3(0,0,0)

    var scene: SCNScene {
        let s = myscene
        addEditorTools(s: s)
 
        let bbx = s.rootNode.childNode(withName: "MyBounding", recursively: false)!
            bbx.position = center
            bbx.scale = scale
        if let ar = s.rootNode.childNode(withName: "arrow", recursively: false ) {
            let bl =  simd_float3(bbx.position) - (simd_float3(bbx.boundingBox.max) - simd_float3(bbx.boundingBox.min))/2.0 
            ar.position = SCNVector3(bl)

        }
        return s

    }
    var bbox: SCNNode? {
        if let bbx = scene.rootNode.childNode(withName: "MyBounding", recursively: false) {
            let bb  = bbx.boundingBox
            let pw = (simd_float3(bb.max) - simd_float3(bb.min)) * simd_float3(bbx.scale)
            let pori = bbx.position
            let bx2 = SCNBox(width: CGFloat(pw.x), height: CGFloat(pw.y), length: CGFloat(pw.z), chamferRadius: 0.3)
            bx2.materials.first?.diffuse.contents = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
            let nx2 = SCNNode(geometry: bx2)
            nx2.position = pori
            return nx2
        }
        return nil
            
    }
    var body: some View {
        VStack{
            HStack {
                Slider(value: $scale.x, in:0 ... 2).background(.red)
                Slider(value: $scale.y, in:0 ... 2).background(.green)
                Slider(value: $scale.z, in:0 ... 2).background(.blue)
            }
            HStack {
                Slider(value: $center.x, in:-1 ... 1).background(.red)
                Slider(value: $center.y, in:-1 ... 1).background(.green)
                Slider(value: $center.z, in:-1 ... 1).background(.blue)
                Button("X") {
                    if let bbx = bbox {
                     scene.rootNode.addChildNode(bbx)
                    print(bbx.position)
                    }
                }
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
    @State var scene: SCNScene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
    
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


