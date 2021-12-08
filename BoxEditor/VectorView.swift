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
        var rotmat = simd_float3x3()
    }
    @State var origNode: SCNNode?
    @State var origMaterial: SCNMaterial?
    @State var origMaterialIndex: Int = 9
    @State var origWorldNormal = simd_float3(1,1,1)
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
             if let p = origNode {
                 if origMaterial != nil {
//                    normalizeNode(old) // reset translation
                     p.geometry?.replaceMaterial(at: origMaterialIndex, with: origMaterial!)
                     print("   Normal: ",origWorldNormal)
                     print("End Trans: ",p.simdTransform)
                     print("End Pivot: ",p.simdPivot)
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
                        origNormal = nd.simdLocalNormal
                        origWorldNormal = nd.simdWorldNormal


                        if let geo = p.geometry {
                            origMaterialIndex = nd.geometryIndex
                            origMaterial = geo.materials[nd.geometryIndex]
                            geo.replaceMaterial(at: nd.geometryIndex, with: selectedMaterial)
                         }
                    } else if let p = camera.parent {
                        // Chenge camera
                            origNode = p
                            origMaterial = nil
                            origWorldNormal = simd_float3(1,1,1)
                    }
                }
            }
        }
        .updating($gstate) { values, state, trans in
            if let c = state.cameraHolder {
                if let value = values.first {

                    let hy1 = 1 * Float(value.translation.height/self.nview.frame.height)
                    let wx1 = 1 * Float(value.translation.width/self.nview.frame.width)
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
                    let angle = Float(value.radians)
//                    c.simdRotation = simd_float4(origNormal,angle)
                    c.pivot = SCNMatrix4MakeRotation(CGFloat(angle), CGFloat(origNormal.x), CGFloat(origNormal.y), CGFloat(origNormal.z))
                }
                if let value = values.second?.second {
                    // Magnification/Wor
                    let value = 1/Float(value)
//                    print (value)
                    if value > 0.1 && value < 10 {
//                        let scaleVector = state.quatf.act(SIMD3<Float>(value,value,1))
                        if origMaterial == nil {
                            let scaleVector = SIMD3<Float>(value,value,value)
    //                        print(scaleVector.debugDescription)
                            c.simdPivot[0,0] = scaleVector[0]
                            c.simdPivot[1,1] = scaleVector[1]
                            c.simdPivot[2,2] = scaleVector[2]
                        } else {

                            let scaleVector = state.rotmat * SIMD3<Float>(value,value,1)
    //                        print(scaleVector.debugDescription)
                            c.simdPivot[0,0] = scaleVector[0]
                            c.simdPivot[1,1] = scaleVector[1]
                            c.simdPivot[2,2] = scaleVector[2]
                        }
                    }

                    
//                    c.simdPivot = simd_float4x4(diagonal: SIMD4<Float>(value,value,value,1))
//                    c.simdScale = SIMD3<Float>( mag) * state.zoomOffset
//                                               origNormal.y != 0 ? value : 1,
//                                               origNormal.z != 0 ? value : 1)
                }
            } else if let p = origNode {
                // Initialize state
//                    updateOrientation(of: p)
                normalizeNode(p) // reset pivot
                 print("Fix Pivot: ",p.simdPivot)
                    state.cameraHolder      = p
                    state.rotationOffset    = p.simdEulerAngles
                    state.locationOffset    = p.simdPosition
                    state.zoomOffset        = p.simdScale
                
                    // Calculate translation plane
                    let cp = simd_cross(SIMD3<Float>(0,0,1),origWorldNormal)
                    let an = acos(simd_dot( SIMD3<Float>(0,0,1) , origWorldNormal))
                    state.quatf  = simd_quatf(angle: an, axis: cp).normalized
                
                    let cp1 = simd_cross(SIMD3<Float>(0,0,1),origNormal)
                    let an1 = acos(simd_dot( SIMD3<Float>(0,0,1) , origNormal))
                    state.rotmat = matrix_float3x3(simd_quatf(angle: an1, axis: cp1).normalized)
                
                
                    print("Quatf: ",state.quatf.debugDescription)
//                    print("Drag: ",cp.debugDescription,an.debugDescription)
//                    print("Tr: ",p.simdTransform.debugDescription)
                    print("Beg Pivot: ",p.simdPivot.debugDescription)
                    print("Beg Trans: ",p.simdTransform.debugDescription)
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
