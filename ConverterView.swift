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
    @State var scale: Double = 0
    @State var newScene: Bool = false
//    @Observable var currentView: URL?
    
    var scene: SCNScene? {

        if let fileURL = converter.model {
              converter.model = nil
//            if currentView != fileURL {
//            currentView = fileURL
            
            if let s = try? SCNScene(url: fileURL) {
                
//                if let bb = s.rootNode.childNode(withName: "BB", recursively: true) {
//                    print("WOrk??")
//                    let box=BoundingBox(min:SIMD3(bb.boundingBox.min),max:SIMD3(bb.boundingBox.max))
//                    let tr = Transform(scale: bb.simdScale)
//                    let geom = Request.Geometry(bounds: box,transform: tr)
////                    if converter.bbox != bb {
////                        converter.bbox = bb
//                        converter.boundingBox = geom
////                    }
//                } else {
//                    let bb = s.rootNode.boundingBox
//                    let w = bb.max - bb.min
//                    let bx=SCNBox(width:w.x,height: w.y, length: w.z,chamferRadius: 0.1)
//                    let node = SCNNode(geometry: bx)
//                    s.rootNode.addChildNode(node)
//                }
                converter.viewedScene = s
                return s;
            }
        }

        
        return converter.viewedScene
     }
 
 
    
    var body: some View {
         if let s = scene {
             BoundBoxEditorView(myscene: s)
            } else if let f = converter.progressValue {
                ProgressView(value: f)
            } else {
                Text("Please select a directory or movie to convert")
            }
         
    }
}



//                if {
//
//                }
//                if let b = converter.boundingBox {
//                    let w=(b.bounds.max-b.bounds.min)
//                    let bx=SCNBox(width: CGFloat(w.x),height: CGFloat(w.y),length: CGFloat(w.z),chamferRadius: 0.01)
//                    bx.firstMaterial?.diffuse.contents = Color("aqua")
//                    bx.firstMaterial?.specular.contents = Color("white")
//                    bx.firstMaterial?.emission.contents = Color("blue")
//                    bx.firstMaterial?.transparency = 0.4
//
////                    boxnode.rotate(by: <#T##SCNQuaternion#>, aroundTarget: <#T##SCNVector3#>)
////                    let boxnode = SCNNode(geometry: geometry)
//                    boxnode.rotation = rv
////                    boxnode.scale = sc //scale((scale,scale,scale))
////                    boxnode.localRotate(by: rv)
//                    s.rootNode.addChildNode(boxnode)
//                } else {
//                    let offset: Int = 0
//                    let geometry = SCNBox(width: 0.1 , height: 0.1,
//                                          length: 0.1, chamferRadius: 0.005)
//                    geometry.firstMaterial?.diffuse.contents = Color.black //("aqua")
//                    geometry.firstMaterial?.specular.contents = Color.black //("white")
//                    geometry.firstMaterial?.emission.contents = Color.black //("blue")
//                    let boxnode = SCNNode(geometry: geometry)
//                    boxnode.rotation = rv
//
//                for xIndex:Int in -2...2 {
//                    for yIndex:Int in -2...2 {
//                        let boxCopy = boxnode.copy() as! SCNNode
//
//                        boxCopy.position.x = CGFloat(xIndex - offset)/3
//                        boxCopy.position.y = CGFloat(yIndex - offset)/3
//                        //self.
//                        s.rootNode.addChildNode(boxCopy)
//                    }
//                }
//                }
//

