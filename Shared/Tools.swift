//
//  Tools.swift
//  test3ds
//
//  Created by Thilo Jeremias on 06.11.21.
//

import Foundation
import SceneKit

//func *(vector:SCNVector3, multiplier:SCNFloat) -> SCNVector3 {
// 
//    return SCNVector3(vector.x * multiplier, vector.y * multiplier, vector.z * multiplier)
//}
//func -(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
// 
//    return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
//}
//func +(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
// 
//    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
//}

func makeBBox(_ ch: SCNNode) -> SCNNode {
    let bb = ch.boundingBox
//    let dm = bb.max - bb.min
    let dm = simd_float3(bb.max) - simd_float3(bb.min)
    let box = SCNBox(width:  CGFloat(dm.z), height: CGFloat(dm.y), length: CGFloat(dm.x), chamferRadius: 0.01)
    box.firstMaterial?.diffuse.contents = CGColor(red:0,green: 0.8,blue: 0,alpha: 0.4)
    let nd = SCNNode(geometry: box)
    return nd
}
