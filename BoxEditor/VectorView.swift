//
//  Vectors.swift
//  RealityKit-Sample
//
//  Created by Thilo Jeremias on 25.11.21.
//

import SwiftUI
import SceneKit
import RealityKit

extension Gesture {

    public func tagging<State>(_ state: GestureState<State>, body: @escaping (Self.Value, inout State, inout Transaction) -> Void) -> GestureStateGesture<Self, State> {
        print("Hello")
        return self as! GestureStateGesture<Self, State>
    }
    
}

struct VectorView: View {

    @EnvironmentObject var sceneViewStore: SceneData
    @State var nview: SCNView
    @State var undoStack = NodeStack()
    @State var selectedMaterial: SCNMaterial
    @State var camera: SCNNode
//    var vx: Binding<String>?
//    var nurl: Binding<URLFileResourceType>?
////    var sceneurl: Binding<URL?>?
//    @Binding var url: URL?
//    @State var xxx = URL(string: "")
    
    init() {
        let view = SCNView()
        let scene = initScene3()
        let cam:SCNNode
        if  let camn = scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil}).first {
            // no cam
            cam = camn
        }
        else {
            cam = SCNNode()
            cam.camera = SCNCamera()
            view.scene?.rootNode.addChildNode(cam)
        }
        let mat = SCNMaterial()
//        mat.diffuse.contents = UIColor(Color.purple).cgColor
        mat.diffuse.contents = NSColor(Color.purple).cgColor
//        let sc = sceneViewStore.sceneObject.rootNode
//        view.scene?.rootNode.addChildNode(sc)
//        self.url = nil
        view.scene = scene
        self.nview = view
        self.selectedMaterial = mat
        self.camera = cam
     }

    struct GState {
        var cameraHolder: SCNNode?
        var rotationOffset = simd_float3(0,0,0)
        var locationOffset = SIMD3<Float>(0,0,0)
        var zoomOffset = simd_float3(0,0,0)
        var quatf = simd_quatf()
    }
    @State var origNode: SCNNode?
    @State var origMaterial: SCNMaterial?
    @State var origMaterialIndex: Int = 9
    @State var origNormal = simd_float3(1,1,1)

    // manipulating objects:
    // on start, all transformations is moved into the pivot (normalizeNode)
    // rotation:  around normal of hit point surface     set rotation & normal axis
    // magnification:  around normal of hitted surface   set scaling perpedicular to normal
    // dragging:  along plane of hitted surface    using transform
    //
    @GestureState var gstate = GState()
    func updatingView(values: SimultaneousGesture<DragGesture, SimultaneousGesture<RotationGesture, MagnificationGesture>>.Value,
                 state: inout GState){
    }
    var dragGesture: some Gesture {
    SimultaneousGesture( DragGesture(minimumDistance: 0) ,
                         SimultaneousGesture(
                        RotationGesture(),
                         MagnificationGesture(minimumScaleDelta:
                                                0)))
        .onEnded(){ value in
             if let old = origNode {
                 if origMaterial != nil {
                    normalizeNode(old) // reset translation
                    old.geometry?.replaceMaterial(at: origMaterialIndex, with: origMaterial!)
//                                      updateOrientation(of: old)
                 }
                origNode = nil
                print("restore")
            }
        }
        .onChanged(){ values in
            if origNode == nil {
                if let value = values.first {
                    let hit = nview.XhitTest(value.startLocation, options: [:])
                    if let nd = hit.first {
                        // Changing an object
                        let p = nd.node
                        self.undoStack.push(node: p)
                        origNode = p
                        print(p.simdPivot)
                        print(p.simdTransform)
                        // Get bounding box and find oposite face
                        let b1 = p.boundingBox.min
                        let b2 = p.boundingBox.max
                        let n  = nd.localNormal
                        origNormal = nd.simdLocalNormal
                        print("Normal: ",origNormal)
                        let x  = n.x > 0.5 ? b2.x : n.x < -0.5 ? b1.x : 0
                        let y  = n.y > 0.5 ? b2.y : n.y < -0.5 ? b1.y : 0
                        let z  = n.z > 0.5 ? b2.z : n.z < -0.5 ? b1.z : 0
//                        p.pivot = SCNMatrix4MakeTranslation(x, y, z) //(0, x, y, z)
//                        SCNMatrix4MakeRotation(<#T##angle: Float##Float#>, <#T##x: Float##Float#>, <#T##y: Float##Float#>, <#T##z: Float##Float#>) nd.worldNormal
//                        p.lo
                        
                        if true {
//                            let x = x + p.position.x
//                            let y = y + p.position.y
//                            let z = z + p.position.z
                            normalizeNode(p)  // reset pivot point
                            p.pivot = SCNMatrix4MakeTranslation(-x,-y,-z)
                            p.localTranslate(by:SCNVector3(-x,-y,-z))
//                            updateOrientation(of: p) // reset translation
                            normalizeNode(p)  // reset pivot point
                        } else {
                            //  O = P * T
//                            let invpiv = simd_inverse(p.simdPivot)
//                            p.simdTransform = simd_mul(invpiv,p.simdTransform)
//                            let point = SIMD3<Float>(Float(x),Float(y),Float(z))
//                            let trans = SCNMatrix4MakeTranslation(x,y,z)
//                            p.simdLocalTranslate(by:point)
//                            let invTran = simd_inverse(p.simdTransform)
//                            p.simdPivot = simd_mul(invTran,trans)
//                            let x = x + p.position.x
//                            let y = y + p.position.y
//                            let z = z + p.position.z
                            let point = SCNVector3(Float(x),Float(y),Float(z))
                            let trans = SCNMatrix4MakeTranslation(x,y,z)
                            
                            p.localTranslate(by:point)
                            let invpiv = SCNMatrix4Invert(p.pivot)
                           p.transform = SCNMatrix4Mult(invpiv, p.transform)
                                // moved pivot into transform
                            let invTran = SCNMatrix4Invert(p.transform)
                            p.pivot = SCNMatrix4Mult(invTran, trans)
                            p.transform = SCNMatrix4Identity
                        }
                        print("Trans: ",p.simdTransform)
                        print("Pivot: ",p.simdPivot)
                        
                        
                        
                        
                        
                        if let geo = p.geometry {
                            origMaterialIndex = nd.geometryIndex
                            origMaterial = geo.materials[nd.geometryIndex]
                            geo.replaceMaterial(at: nd.geometryIndex, with: selectedMaterial)
                         }
                    } else if let p = camera.parent {
                        // Chenge camera
                            origNode = p
                            origMaterial = nil
                            origNormal = simd_float3(1,1,1)
                    }
                }
            }
        }
        .updating($gstate) { values, state, trans in
            if let c = state.cameraHolder {
                if let value = values.first {

                    let hy1 = 2 * Float(value.translation.height/self.nview.frame.height)
                    let wx1 = 2 * Float(value.translation.width/self.nview.frame.width)
                    let hy = sin(hy1)
                    let wx = sin(wx1)

                    if origMaterial == nil {
                    // Dragging / Camera rotation
                        let y = hy * .pi
                        let x = wx * .pi
                        c.simdEulerAngles = state.rotationOffset + simd_float3(-y,-x,0)
                    } else {
                        // Dragging object along the normals plane
                        let ov = SIMD3<Float>(wx,-hy,0) * 20.0
                        let r = state.quatf.act(ov)
                        c.simdPosition = r + state.locationOffset
                    }
                }
                if let value = values.second?.first {
                    // rotation
                    let angle = Float(-value.radians)
                    c.simdRotation = simd_float4(origNormal,angle)
//                    c.simdRotation.w = angle;
//                    let myqf= state.quatf.angle + angle
//                    c.simdRotation = state.quatf.act(SIMD3<Float>(1,0,0))
                }
                if let value = values.second?.second {
                    // Magnification
                    let value = Float(value)
                    let vec = simd_cross(SIMD3<Float>(value,value,value), origNormal)
                    let mag = state.zoomOffset * (vec + origNormal)
                    c.simdScale = mag
                }
            } else if let p = origNode {
                // Initialize state
                    state.cameraHolder      = p
                    state.rotationOffset    = p.simdEulerAngles
                    state.locationOffset    = p.simdPosition
                    state.zoomOffset        = p.simdScale
                    let cp = simd_cross(SIMD3<Float>(0,0,1),origNormal)
                    let an = acos(simd_dot( SIMD3<Float>(0,0,1) , origNormal))
                    state.quatf  = simd_quatf(angle: an, axis: cp)
                if cp == SIMD3<Float>(0,0,0) {
                    print("NULL")
                    state.quatf  = simd_quatf(angle: an, axis: SIMD3<Float>(0,1,0))
                }
                print("Drag: ",cp.debugDescription,an.debugDescription)
                print("Tr: ",p.simdTransform.debugDescription)
            }
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            SceneViewX(sview: $nview, //$sceneViewStore.view,
               pointOfView: self.camera,
                options: [
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                    ]
                  )
                 .gesture(dragGesture)
                 .onAppear(perform: {
//                     if let url = self.url {
//                             if let scene = try? SCNScene(url:url) {
//                                 sceneViewStore.sceneObject = scene
//                             }
//                     }
                     nview.scene = sceneViewStore.sceneObject
                     if let cam = sceneViewStore.sceneObject.rootNode.childNodes(passingTest: { node,p in node.camera != nil}).first {
                         camera = cam
                     }
                 })
            VStack(alignment: .leading){
                Spacer()
                HStack() {
                Button("XUndo (\(undoStack.size.description))"){
                    print("Undo \(undoStack.size.description)")
                    self.undoStack.pop()
                }
                .keyboardShortcut("z", modifiers: [.command])
                .disabled(undoStack.size == 0)

            Button("ResetView"){
                if let cam = nview.scene?.rootNode.childNodes(passingTest: {node,p in node.camera != nil}).first {
                    camera = cam
                    if let anode = cam.parent {
                        anode.transform = SCNMatrix4Identity
                        print("Update")
                    }

                }
            }
                }
//                .background(Color.red)

        }
    }
    }
}

//struct Vectors_Previews: PreviewProvider {
//    static var previews: some View {
//        VectorView()
//    }
//}
