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
        let scene = createScene2()
        let view  = SCNView()
        
        view.scene = scene
        self.view = view
        self.sceneObject = scene
    }

}


fileprivate func createScene2() -> SCNScene {
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
