//
//  File.swift
//  test3ds
//
//  Created by Thilo Jeremias on 03.11.21.
//
import SwiftUI
import SceneKit
import RealityKit
func *(vector:SCNVector3, multiplier:SCNFloat) -> SCNVector3 {
 
    return SCNVector3(vector.x * multiplier, vector.y * multiplier, vector.z * multiplier)
}


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
                
                if let bb = s.rootNode.childNode(withName: "BB", recursively: true) {
                    print("WOrk??")
                    let box=BoundingBox(min:SIMD3(bb.boundingBox.min),max:SIMD3(bb.boundingBox.max))
                    let tr = Transform(scale: bb.simdScale)
                    let geom = Request.Geometry(bounds: box,transform: tr)
//                    if converter.bbox != bb {
//                        converter.bbox = bb
                        converter.boundingBox = geom
//                    }
                }
                converter.viewedScene = s
                return s;
            }
        }

        
        return converter.viewedScene
     }
 
    var cameraNode: SCNNode? {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        cameraNode.camera?.zNear = 0.1
        return cameraNode
    }
 
    fileprivate func createBox(_ s: SCNScene) {
        let rv: SCNQuaternion = SCNQuaternion(scale,scale,scale,scale)
        let sc = SCNVector3Make(scale,scale,scale)
        let b = SCNBox(width: 1,height: 1,length: 1,chamferRadius: 0.1)
        let boxnode = SCNNode(geometry: b)
        //                boxnode.simdScale = SIMD3(Float(scale),Float(scale),Float(scale)) //.simscale = $scale
        boxnode.scale = sc
        s.rootNode.addChildNode(boxnode)
    }
    
    var body: some View {
        VStack {
        if let s = scene {
            HStack {
            Slider(
                 value: $scale,
                 in: 0...2,
                 onEditingChanged: {_ in
                     print("S:\(scale)")
                 }
             )
            Button("Do") {createBox(s)}
            }

            SceneView(
                scene: s,
                pointOfView: cameraNode,
                options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                ]
            ).onAppear(perform: { })
                
            } else if let f = converter.progressValue {
                ProgressView(value: f)
            } else {
                Text("Please select a directory or movie to convert")
            }
        }
        Spacer()
        
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

