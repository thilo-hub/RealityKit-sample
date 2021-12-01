//
//  SceneClass.swift
//  RealityKit-Sample
//
//  Created by Thilo Jeremias on 23.11.21.
//

import Foundation
import SwiftUI
import SceneKit

final class SceneData: ObservableObject {
    @Published public var sceneObject:SCNScene
    @Published public var view: SCNView

    init(){
        let scene = initScene1()
        let view  = SCNView()
        
        view.scene = scene
        self.view = view
        self.sceneObject = scene
    }

}


func initScene1() -> SCNScene {
    print("init")
    let scene = SCNScene(named: "SceneAssets.scnassets/Arrows.dae")!

    // Create Camera holder
    let cams = SCNNode()
    let cmh = SCNNode()
    cmh.addChildNode(cams)
    let cam = SCNNode()
    cam.addChildNode(cmh)
    cams.camera = SCNCamera()
    cams.position = SCNVector3(0,0,20)
    cam.name = "camera"
    scene.rootNode.addChildNode(cam)

    let pne = SCNPlane(width: 10, height: 10)
    let pnn = SCNNode(geometry: pne)
    pne.materials[0].isDoubleSided = true
    pnn.eulerAngles.x =  .pi/2.0
    pnn.position = SCNVector3(x:0,y:0,z:0)
    scene.rootNode.addChildNode(pnn)

    var names = ["X","Y","Z"]
    for i:simd_float3 in [[10,0,0],[0,10,0],[0,0,10]] {
        let bx = SCNBox(width: 1, height: 2, length: 3, chamferRadius: 0.1)
        let nd = SCNNode(geometry: bx)
        //            bx.materials[0].diffuse.contents = defaultSurface

        nd.simdPosition = i
        nd.name = names.removeFirst()
        scene.rootNode.addChildNode(nd)
    }
    return scene
}
func initScene2() -> SCNScene {
    let scene = SCNScene()
    func makeArrow(color: CGColor) -> SCNNode {
        let arrtail = SCNNode(geometry: SCNCylinder(radius:0.5,height:6))
        let arrhead = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 1.3, height: 3))
        arrhead.position = SCNVector3(x: 0, y: 7.5, z: 0)
        arrtail.position = SCNVector3(x: 0, y: 3, z: 0)
        let arrow = SCNNode()
        let cmat = SCNMaterial()
        cmat.diffuse.contents = color
        arrhead.geometry?.firstMaterial = cmat
        arrow.addChildNode(arrtail)
        arrow.addChildNode(arrhead)
        
        return arrow
    }
    
    let arrowBlue  = makeArrow( color: CGColor(red: 0, green: 0, blue: 1, alpha: 1))
    let arrowRed   = makeArrow( color: CGColor(red: 1, green: 0, blue: 0, alpha: 1))
    let arrowGreen = makeArrow( color: CGColor(red: 0, green: 1, blue: 0, alpha: 1))
    
    let rv:Float = .pi/2.0
    
    arrowRed.simdEulerAngles.x = rv //.pi/2
    arrowRed.simdEulerAngles.y = rv // .pi/4
    arrowRed.simdEulerAngles.z = rv // .pi/4
    scene.rootNode.addChildNode(arrowRed)
    scene.rootNode.addChildNode(arrowGreen)
    scene.rootNode.addChildNode(arrowBlue)
    
    
    arrowRed.simdEulerAngles  = simd_float3(.pi/2, 0, 0)
    arrowBlue.simdEulerAngles = simd_float3(0, .pi/2, 0)
    arrowGreen.simdEulerAngles = simd_float3(0, 0, .pi/2)
    
    arrowGreen.simdTransform = arrowBlue.simdTransform + arrowRed.simdTransform
    
    let plane = SCNNode(geometry: SCNFloor())
    scene.rootNode.addChildNode(plane)
    return scene
}

