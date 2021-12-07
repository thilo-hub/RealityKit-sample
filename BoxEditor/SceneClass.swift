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
    @Published public var sceneObject:SCNScene = SCNScene()

    init(){
        sceneObject = initScene3()
        addCamera(sceneObject)
    }

}


fileprivate func addCamera(_ scene: SCNScene) {
    // Create Camera holder
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(0,0,20)
    
    let cameraHolder = SCNNode()
    cameraHolder.addChildNode(cameraNode)
    
    let cameraBox = SCNNode()
    cameraBox.addChildNode(cameraHolder)
    cameraBox.name = "camera"
    scene.rootNode.addChildNode(cameraBox)
}

func initScene1() -> SCNScene {
    print("init")
    let scene = SCNScene(named: "SceneAssets.scnassets/Arrows.dae")!

//    addCamera(scene)

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

fileprivate func addFancyCam(_ scene: SCNScene) {
    //    let scene = SCNScene(named: "MyScene.scnassets/ship.scn")!
    let camn = SCNNode()
    let cam = SCNCamera()
    camn.position = SCNVector3(0,1,30)
    camn.camera = cam
    
    let cbox = SCNBox(width: 2.5,height: 2.5,length: 2.5,chamferRadius: 0)
    let camh = SCNNode(geometry: cbox)
    camh.addChildNode(camn)
    cbox.removeMaterial(at: 0)
    let skyBlue = Color(red: 0.4627, green: 0.8392, blue: 1.0)
    //    let lemonYellow = Color(hue: 0.1639, saturation: 1, brightness: 1)
    let steelGray = Color(white: 0.4745)
    for color in [ Color.red, Color.green, Color.blue, Color.yellow, skyBlue, steelGray] {
        let mat = SCNMaterial()
        //        mat.diffuse.contents = UIColor(color).cgColor
        mat.diffuse.contents = NSColor(color).cgColor
        cbox.materials.append(mat)
    }
    scene.rootNode.addChildNode(camh)
}

func initScene3()  -> SCNScene {
    let scene = initScene1()
//    addFancyCam(scene)
    return scene
}
