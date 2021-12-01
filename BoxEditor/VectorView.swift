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
fileprivate func initScene3()  -> SCNView {
    let view = SCNView()
    let scene = initScene1()
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
        mat.diffuse.contents = UIColor(color).cgColor
        cbox.materials.append(mat)
    }
    scene.rootNode.addChildNode(camh)
    view.scene = scene
    return view
}

struct VectorView: View {

    @State var nview: SCNView
    @State var undoStack = NodeStack()
    @State var selectedMaterial: SCNMaterial
    @State var camera: SCNNode
    
    init() {
        let view = initScene3()
        let cam = view.scene?.rootNode.childNodes(passingTest: {node,p in node.camera != nil}).first! ?? SCNNode()
        if cam.camera == nil {
            cam.camera = SCNCamera()
        }
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor(Color.purple).cgColor

        self.selectedMaterial = mat
        self.camera = cam
        self.nview = view
    }

    struct GState {
        var cameraHolder: SCNNode?
        var rotationOffset = simd_float3(0,0,0)
        var zoomOffset = simd_float3(0,0,0)
    }
    @State var origNode: SCNNode?
    @State var origMaterial: SCNMaterial?
    @State var origMaterialIndex: Int = 9

    @GestureState var gstate = GState()
    
    var dragGesture: some Gesture {
    SimultaneousGesture( MagnificationGesture(minimumScaleDelta:
                                                0),DragGesture(minimumDistance: 0) )
        .onEnded(){ value in
             if let old = origNode {
                old.geometry?.replaceMaterial(at: origMaterialIndex, with: origMaterial!)
                origNode = nil
                print("restore")
            }
        }
        .onChanged(){ values in
            if origNode == nil {
                if let value = values.second {
                    let hit = nview.XhitTest(value.startLocation, options: [:])
                    if let nd = hit.first {
                        print(nd.geometryIndex)
                        let p = nd.node
                        
                        self.undoStack.push(node: p)
                        origNode = p
                        if let geo = p.geometry {
                            origMaterialIndex = nd.geometryIndex
                            origMaterial = geo.materials[nd.geometryIndex]
                            geo.replaceMaterial(at: nd.geometryIndex, with: selectedMaterial)
                            
                            print("save")
                        }
                    } else if let p = camera.parent {
                            origNode = p
                            origMaterial = nil
                    }
                }
            }
        }
        .updating($gstate) { values, state, trans in
            if let c = state.cameraHolder {
                if let value = values.second {
                    let y = value.translation.height / self.nview.frame.height * .pi
                    let x = value.translation.width / self.nview.frame.width * .pi
                    c.simdEulerAngles = state.rotationOffset + simd_float3(Float(y),Float(x),0)
                }
                if let value = values.first {
                    let mag = state.zoomOffset / Float(value)
                    c.simdScale = mag
                }
            } else if let p = origNode {
                    state.cameraHolder      = p
                    state.rotationOffset    = p.simdEulerAngles
                    state.zoomOffset        = p.simdScale
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
            VStack(alignment: .leading){
                Spacer()
//                Slider(value: $rotx, in: -.pi/2 ... .pi/2){ vv in //                    anode.simdEulerAngles.y = rv }
                HStack() {
//                    Text(gstate?.simdEulerAngles.x, format:"X: %2.2f")
//                    Text("X: \((gstate.rot[0]), specifier: "%.2f")")
//                    Text("Y: \((gstate.rot[1]), specifier: "%.2f")")
//                    Text("Z: \((gstate.rot[2]), specifier: "%.2f")")
//                    Text("W: \((gstate.rot[3]), specifier: "%.2f")")
//                    Text(String(format:"%3.3f",Float?(camloc?.simdEulerAngles.x)))
                
                Button("XUndo (\(undoStack.size.description))"){
                    print("Undo \(undoStack.size.description)")
                    self.undoStack.pop()
                }
                .keyboardShortcut("z", modifiers: [.command])
                .disabled(undoStack.size == 0)

            Button("ResetView"){
                if let cam = nview.scene?.rootNode.childNodes(passingTest: {node,p in node.camera != nil}).first {
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

struct Vectors_Previews: PreviewProvider {
    static var previews: some View {
        VectorView()
    }
}
