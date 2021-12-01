//
//  ContentView.swift
//  ViewTests
//
//  Created by Thilo Jeremias on 15.11.21.
//

import SwiftUI
import SceneKit

let box_name = "Box"
fileprivate func createScene() -> SCNScene {
    let sc = SCNScene(named:"MyScene.scnassets/Arrows.dae")!

    let camn = SCNNode()
    let cam  = SCNCamera()
    camn.camera = cam
    camn.position = SCNVector3(0,0,40)
    sc.rootNode.addChildNode(camn)

    
    let plane  = SCNPlane(width: 20,height: 20)
    plane.materials[0].diffuse.contents = CGColor(red: 0, green: 0, blue: 1, alpha: 0.5)
    plane.materials[0].isDoubleSided = true

    let planen = SCNNode(geometry: plane)
    planen.position = SCNVector3(0,0,0)
    planen.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Angle(degrees:-90).radians)
//    sc.rootNode.addChildNode(planen)
    
    let box  = SCNBox(width: 5, height: 7, length: 9, chamferRadius: 0.5)
    let boxn = SCNNode(geometry: box)
    boxn.name = box_name
    sc.rootNode.addChildNode(boxn)
    updateOrientation(of: camn)

    return sc
}
private func changeOrientation(of node: SCNNode, with translation: CGSize) {
    let x = Float(translation.width)
    let y = Float(-translation.height)

    let anglePan = sqrt(pow(x,2)+pow(y,2)) * (Float)(Double.pi) / 180.0

    var rotationVector = SCNVector4()

    rotationVector.x = CGFloat(-y)
    rotationVector.y = CGFloat(x)
    rotationVector.z = 0
    rotationVector.w = CGFloat(anglePan)

    node.rotation = rotationVector
}

//private func updateOrientation(of node: SCNNode) {
//    let currentPivot = node.pivot
//    let changePivot = SCNMatrix4Invert(node.transform)
//    node.pivot = SCNMatrix4Mult(changePivot, currentPivot)
//    node.transform = SCNMatrix4Identity
//}
struct ContentView: View {
    @State var scnview = SCNView()
    var scene: SCNScene = createScene()
    
    var exclusiveGesture: some Gesture {
        ExclusiveGesture(drag, magnify)
    }
    @State var isDragging = false
    @State var dragTarget: SCNNode?
    @State var dragDirection: SCNVector3?
    
    fileprivate func DragBox(_ value: DragGesture.Value, _ box: SCNNode) {
        let f1 = simd_float2(Float(value.translation.width),Float(value.translation.height))
        //            var scale = simd_length(f1)/20
        var scale = Float(value.translation.width)/20
        let dir: simd_float3 = simd_float3(dragDirection!) // simd_float3(1,0,0)
        
        let min: simd_float3
        let max: simd_float3
        let P: simd_float3
        if ( (dragDirection!.x+dragDirection!.y+dragDirection!.z) > 0 ) {
            min = simd_float3(box.boundingBox.min)
            max = simd_float3(box.boundingBox.max)
            P  = max + min * scale
        } else {
            max = simd_float3(box.boundingBox.min)
            min = simd_float3(box.boundingBox.max)
           
            P = max * scale + min
            scale *= -1
        }
        
//        let P = (min+max*scale)*dir
        
        box.position = SCNVector3(P * dir )
        box.scale = SCNVector3( dir*(scale-1) + 1.0)
    }
    @State var oldn: [SCNNode] = [] // = SCNNode()
    
    fileprivate func DragObject(_ value: DragGesture.Value) {
        if !self.isDragging {
        isDragging = true
          dragTarget = nil
//            print (value.location,value.startLocation)
            var hitTestOptions = [SCNHitTestOption.sortResults : NSNumber(value: true),
                                  SCNHitTestOption.boundingBoxOnly : NSNumber(value: true)]

            if #available(iOS 11.0, *) {
                hitTestOptions[SCNHitTestOption.searchMode] = SCNHitTestSearchMode.all.rawValue as NSNumber
            }
         
            let tgt = scnview.XhitTest(value.location, options: hitTestOptions            )
            if  tgt.count > 0 {
                tgt.forEach({ target in
                        
                    let ball  = SCNSphere(radius: 0.6)
                    let balln = SCNNode(geometry: ball)
                    if oldn.count > 10 {
                        let dn = oldn.removeFirst()
                        dn.removeFromParentNode()
                    }
                    oldn.forEach({node in node.simdScale = node.simdScale * 0.8})
                    oldn.append(balln)
                    balln.position = tgt[0].localCoordinates
                    scene.rootNode.addChildNode(balln)
                        
                })
                
                print(tgt.count, value.translation)
                let tg1 = tgt.filter({$0.node.name == box_name})
                if let bx = tg1.map({ $0.node }).first {
                    dragTarget = bx
                    dragDirection = tg1[0].localNormal
                    dragDirection = SCNVector3(0,0,0)
                    // Try finding the orientation to camera
//                    print("BB: \(bx.boundingBox )")
//                    print("Geo: \(tg1[0].faceIndex) C:\(tg1[0].localNormal)")
                    // Guess face
                    bx.geometry?.materials[0].diffuse.contents = CGColor(red: 0.8, green: 0, blue: 0.3, alpha: 0.9)

                    
                }
            }
        }
        
        if let box = dragTarget {
            DragBox(value, box)
        } else {
            if let cam = scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil}).first {
                changeOrientation(of: cam,  with: value.translation)
            }
        }
    }
    
    fileprivate func DragObjectEnded() {
        if let e = dragTarget {
            e.geometry?.materials[0].diffuse.contents = CGColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.9)
          updateOrientation(of: e)
            dragTarget = nil
        } else {
            if let cam = scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil}).first {
                updateOrientation(of: cam )
            }
            isDragging = false
        }
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                DragObject(value)
            }
            .onEnded { value in
                DragObjectEnded()
            }
    }
    @GestureState var magnifyBy = CGFloat(1.0)
    @State var modcam = true
    @State var startMag: CGFloat?
    fileprivate func MagnifyCam(_ value: MagnificationGesture.Value) {
        if let cam = scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil}).first?.camera {
            let newfocal: CGFloat
            if let mag = startMag {
                let nmag = mag * value
                if 1 < nmag && nmag < 100 {
                    newfocal = nmag
                } else {
                    newfocal = cam.focalLength
                }
            } else {
                newfocal = cam.focalLength
                startMag = newfocal
            }
            cam.focalLength = newfocal
        }
    }
    
    var magnify: some Gesture {
        MagnificationGesture()
            .onChanged{ (value) in 
                MagnifyCam(value)
             }
            .onEnded{ value in
                startMag = nil
             }
    }

    var onTap: some Gesture {
        TapGesture( count: 1)
            .onEnded{ value in
                print("Tap: \(value)")
             }
    }

    
    
    
    
    
    var body: some View {
         HStack{
            
            // Make a scene per camera
            ForEach( scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil}), id:\.self)  { n in
            
            SceneViewX (
                sview: $scnview,
                scene: scene,
                pointOfView: n,
                options: [
//                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                    ]
                )
//                    .gesture(onTap)
                .gesture(exclusiveGesture)

            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
