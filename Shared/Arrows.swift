//
//  Arrows.swift
//  RealityKit-Sample (macOS)
//
//  Created by Thilo Jeremias on 09.02.22.
//

import Foundation
import SceneKit

func addArrow(scene: SCNScene,location:SCNVector3, maxlen:CGFloat)->SCNNode{
    let xG = SCNCylinder(radius: maxlen/20, height: maxlen)

    let yG = SCNCylinder(radius: maxlen/20, height: maxlen)
    let x = SCNNode(geometry: xG)
    x.position.y = maxlen/2
    let y = SCNNode(geometry: yG)
    y.pivot = SCNMatrix4MakeRotation(.pi/2, 0, 0, 1)
    y.position.x = maxlen/2
    let rN = SCNNode()
    rN.name = "Marker"
    rN.addChildNode(x)
    rN.addChildNode(y)
    x.geometry?.firstMaterial?.diffuse.contents = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
    y.geometry?.firstMaterial?.diffuse.contents = CGColor(red: 0, green: 1, blue: 0, alpha: 1)
//    world.addChildNode(rN)
//        rN.simdPosition = world.simdConvertPosition(  simd_float3(location),from: world)
    rN.simdWorldPosition = simd_float3(location)
    print(rN.simdWorldPosition)
    return rN
    
}
