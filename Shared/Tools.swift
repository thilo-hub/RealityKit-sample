//
//  Tools.swift
//  test3ds
//
//  Created by Thilo Jeremias on 06.11.21.
//

import Foundation
import SceneKit

import os

let logger = Logger(subsystem: "com.apple.sample.photogrammetry",
                            category: "HelloPhotogrammetry")


func makeBBox(_ ch: SCNNode) -> SCNNode {
    let bb = ch.boundingBox
    let dm = simd_float3(bb.max) - simd_float3(bb.min)
    let box = SCNBox(width:  CGFloat(dm.z), height: CGFloat(dm.y), length: CGFloat(dm.x), chamferRadius: 0.01)
    box.firstMaterial?.diffuse.contents = CGColor(red:0,green: 0.8,blue: 0,alpha: 0.4)
    let nd = SCNNode(geometry: box)
    
    
    return nd
}
func updateOrientation(of node: SCNNode) {
    
    // transform^-1 * pivot => pivot, 1 => transform
    // pivot^-1 * transform => transform, 1 => pivot
    
    let currentPivot = node.pivot
    let changePivot = SCNMatrix4Invert(node.transform)
//    totalChangePivot = SCNMatrix4Mult(changePivot, currentPivot)
    node.pivot = SCNMatrix4Mult(changePivot, currentPivot)
    node.transform = SCNMatrix4Identity
}
func normalizeNode(_ node: SCNNode) {
    //                        child.pivot = SCNMatrix4Identity
    //                        updateOrientation(of: child)
    // pivot^-1 * transform => transform, 1 => pivot
    let invpiv = SCNMatrix4Invert(node.pivot)
    node.transform = SCNMatrix4Mult(invpiv, node.transform)
    node.pivot = SCNMatrix4Identity
}
