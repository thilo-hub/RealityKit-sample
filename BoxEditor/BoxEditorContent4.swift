//
//  Shared
//
//  Created by Thilo Jeremias on 21.11.21.
//

import SwiftUI
import SceneKit

struct BoxEditorContent4: View {
    @EnvironmentObject var sceneViewStore: SceneData
//    @State var view: SCNView
    let selectedSurface = CGColor(red: 1, green: 0, blue: 0, alpha: 0.8)
    let defaultSurface = CGColor(red: 0, green: 0, blue: 1, alpha: 0.8)
    @State var otherMaterial = SCNMaterial()
    @State var nview = SCNView()
    @State var camT: SCNMatrix4 = SCNMatrix4Identity
    @State var undoStack = NodeStack()
    init()
    {
        otherMaterial.diffuse.contents = CGColor(red: 1, green: 0, blue: 0, alpha: 0.8)
        otherMaterial.isDoubleSided = true
    }
    
    let mindist = 0.0
    
    fileprivate func rotateOpositePoint(_ nd: SCNNode) {
        // Rotate around point furthest away
        print("New zoom")
        var px = nd.boundingBox.max
        let pp = nd.boundingBox.min
        if dragState.hitp.x > 0 { px.x = pp.x }
        if dragState.hitp.y > 0 { px.y = pp.y }
        if dragState.hitp.z > 0 { px.z = pp.z }
        nd.position = SCNVector3(px.x,px.y,px.z)
        nd.pivot = SCNMatrix4MakeTranslation(px.x,px.y,px.z)
    }
    
    var dragGesture: some Gesture {
        SimultaneousGesture( DragGesture( minimumDistance: mindist), MagnificationGesture())
            .updating($dragState) { values, state, transaction in
                let cam = sceneViewStore.sceneObject.rootNode.childNode(withName: "camera", recursively: true)
                switch state.state {
                    case .idle:
                        if let value = values.first {
                            camT = cam!.worldTransform
                            let hit = nview.XhitTest(value.startLocation, options: [:])
                            if let nd = hit.first {
                                self.undoStack.push(node: nd.node)
                                state.state = .objectMove
                                state.handle = nd.node
                                state.hitp = nd.localCoordinates
                                state.hitn = nd.localNormal
//                                let camr = SCNMatrix4Mult(camT, nd.modelTransform)
//                                print(camr)
//                                if let e = nd.node.geometry?.elements {
////                                    for el in e {
////                                        print(e)
////                                    }
//                                }
                                print(nd.localNormal)
                                print("Object")
                            } else if  cam != nil {
                                state.state = .cameraMove
                                state.handle = cam
                                print("camera")
                                }
                        } else if values.second != nil {
                            if cam != nil {
                                state.state = .cameraZoom
                                state.handle = cam
                                print("camera zoom")
                            }
                        }
                    
                case .objectZoom, .cameraZoom:
                        if let node = state.handle {
                            if let value = values.second {
                                let value = Float(value)
                                
                                if state.state == .cameraZoom {
                                    let mag = Float(1/value)
                                    node.simdScale = simd_float3(x:mag,y:mag,z:mag)
                                } else {
                                    let mag = Float(value)
                                    node.simdScale = simd_float3(x:mag,y:mag,z:mag)
                                }
                            }
                        }
                case .objectMove:
                    if let node = state.handle {
                        if let value = values.first {
                            let v1 = value.translation.width
                            let v = Float(v1 / 400.0)
                            let vv = simd_float3(1,1,1) + v * simd_float3(state.hitn)
                            node.simdScale = vv
                                 
//                            node.transform = SCNMatrix4MakeTranslation(v * vx,v * vy, v * vz)
//                            let w = 2 * .pi  * value.translation.height/self.nview.frame.height
//                            let h = 2 * .pi  * value.translation.width/self.nview.frame.width
//                            node.rotation = SCNVector4(state.hitp.x, state.hitp.y, state.hitp.z,h)

                        }
                    }
                case .objectRotate, .cameraMove:
                        if let node = state.handle {
                            if values.second != nil {
                                state.state = state.state == .cameraMove ? .cameraZoom : .objectZoom
                            } else if let value = values.first {
//                                let value = Float(value)
                                let w = 2 * .pi  * value.translation.height/self.nview.frame.height
                                let h = 2 * .pi  * value.translation.width/self.nview.frame.width
                                node.simdEulerAngles = simd_float3(x:Float(w),y:Float(h),z:0)

                            }
                        }
                    }
            }
            .onChanged({ value in
                if ActiveNode  == nil {
                    // scene -> {selectedNode}
                    // ==> scene -> {NewNode} -> {selectedNode}
                    if let handle = dragState.handle {
                        if let geom = handle.geometry {
//                            self.undoStack.push(node: handle)
                            geom.materials.append(otherMaterial)
                            otherMaterial = geom.materials.removeFirst()
                        }
                        if let parent = handle.parent {
                            let nn = SCNNode()
                            ActiveNode = nn
                            
                            nn.transform = handle.transform
                            
                            handle.transform = SCNMatrix4Identity
                            if dragState.state == .objectMove {
                                
                                rotateOpositePoint(handle)
                                
//                                nd.pivot = SCNMatrix4MakeRotation(0, dragState.hitn.x, dragState.hitn.y, dragState.hitn.z)
                            }
                            if dragState.state == .objectRotate {
                                
                                rotateOpositePoint(handle)
                                
//                                nd.pivot = SCNMatrix4MakeRotation(0, dragState.hitn.x, dragState.hitn.y, dragState.hitn.z)
                            }
                            parent.replaceChildNode(handle, with: nn)
                            nn.addChildNode(handle)
                        }
                    }
                }

            })

            .onEnded { value in
                // Remove rotator node from system applying transformation to child
                // scene -> {NewNode} -> {selectedNode}
                // ==> scene -> {selectedNode}
                if let handle = ActiveNode {
                    ActiveNode = nil
                    if let child = handle.childNodes.first {
                        // Swap red away
                        if let geom  = child.geometry {
                            geom.materials.append(otherMaterial)
                            otherMaterial = geom.materials.removeFirst()
                        }
                        // apply transformation
                        let ntr = SCNMatrix4Mult(child.transform,handle.transform)

                        child.transform = ntr
                            normalizeNode(child)

                        if let parent = handle.parent {
                            parent.replaceChildNode(handle, with: child)
                        }
                    }
                }
            }

        
    }
    struct DragS {
        var state = gestureS.idle
        var dragging = false
        var handle:SCNNode? = nil
        var hitn: SCNVector3 = SCNVector3Zero
        var hitp: SCNVector3 = SCNVector3Zero
    }
    // scene -> {NewNode} -> {selectedNode}
    //
    @State var ActiveNode: SCNNode?
    @GestureState var dragState = DragS()


    
    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.formatted(date: .omitted, time: .standard)
            ZStack {
                SceneViewX(sview: $nview, //$sceneViewStore.view,
                       //    pointOfView: scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil}).first,
    
                    options: [
    //                    .allowsCameraControl,
                        .autoenablesDefaultLighting,
                        .temporalAntialiasingEnabled
                        ]
                      )
                    .onAppear(perform: {
                        nview.scene = sceneViewStore.sceneObject
//                        let v1 = SCNVector3(1,0,0)
//                        let v2 = SCNVector3(0,1,0)
                        for n in ["X","Y","Z"] {
                            if let nd = sceneViewStore.sceneObject.rootNode.childNode(withName: n, recursively: true) {
//                                let v = SCNMatrix4MakeRotation(Angle.degrees(45).degrees, 1, 1, 0)
                                let v = SCNMatrix4Identity
                                let bx1=SCNBox(width: 0.5,height: 0.5,length: 3, chamferRadius: 0)
                                bx1.materials[0].diffuse.contents =
                                CGColor(red: abs(CGFloat(nd.position.x)/10),
                                                green: abs( CGFloat(nd.position.y)/10),
                                                blue: abs( CGFloat(nd.position.z)/10),
                                                alpha: 1)
                                let bxn=SCNNode(geometry: bx1)
                                bxn.transform = SCNMatrix4Mult(nd.transform, v)
//                                bxn.position = nd.position
                                bxn.position.x += 3
                                bxn.position.y += 2
//                                bxn.position.z += 2
                                sceneViewStore.sceneObject.rootNode.addChildNode(bxn)
                                
                            }
                        }
                    })
                VStack() {
                    Text("Version 3")
                    Spacer()
                    HStack() {
                        Button("Undo \(undoStack.size.description)"){
                            print("Undo \(undoStack.size.description)")
                            self.undoStack.pop()
                        }
                        .keyboardShortcut("z", modifiers: [.command])
                        Text( "Run: \( now) ")
                        Spacer()
                        Text( ActiveNode?.childNodes.first?.name ?? "")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .gesture(dragGesture)
        }
    }
}
