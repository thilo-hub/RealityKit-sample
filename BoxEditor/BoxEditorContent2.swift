//
//  Shared
//
//  Created by Thilo Jeremias on 21.11.21.
//

import SwiftUI
import SceneKit

struct BoxEditorView2: View {
    @EnvironmentObject var sceneViewStore: SceneData
    // @State var scene: SCNScene
    @State var view: SCNView
    let selectedSurface = CGColor(red: 1, green: 0, blue: 0, alpha: 0.8)
    let defaultSurface = CGColor(red: 0, green: 0, blue: 1, alpha: 0.8)
    @State var otherMaterial = SCNMaterial()
    init()
    {
        let view = SCNView()
        self.view = view
        otherMaterial.diffuse.contents = CGColor(red: 1, green: 0, blue: 0, alpha: 0.8)
        otherMaterial.isDoubleSided = true
    }
    
    let mindist = 0.0
    var dragGesture: some Gesture {
        SimultaneousGesture( DragGesture( minimumDistance: mindist), MagnificationGesture())
            .updating($dragState) { values, state, transaction in
                let cam = sceneViewStore.sceneObject.rootNode.childNode(withName: "camera", recursively: true)
                switch state.state {
                    case .idle:
                        if let value = values.first {
                            let hit = view.XhitTest(value.startLocation, options: [:])
                            if let nd = hit.first {
                                state.state = .objectRotate
                                state.rotatorNode = nd.node
                                print("Object")
                            } else if  cam != nil {
                                state.state = .cameraMove
                                state.rotatorNode = cam
                                print("camera")
                                }
                        } else if let value = values.second {
                            if cam != nil {
                                state.state = .cameraZoom
                                state.rotatorNode = cam
                                print("camera zoom")
                            }
                        }

                case .objectZoom, .cameraZoom:
                    print("Zoom")
                        if let node = state.rotatorNode {
                            if let value = values.second {
                                let mag = state.state == .cameraZoom ? 1/value : value
                                node.scale = SCNVector3(x:mag,y:mag,z:mag)
                            }
                        }
                case .objectRotate, .cameraMove:
                        if let node = state.rotatorNode {
                            if let value = values.second {
                                state.state = state.state == .cameraMove ? .cameraZoom : .objectZoom
                            } else if let value = values.first {
                                let w = 2 * .pi  * value.translation.height/self.view.frame.height
                                let h = 2 * .pi  * value.translation.width/self.view.frame.width
                                node.eulerAngles = SCNVector3(x:w,y:h,z:0)

                            }
                        }
                    }
            }
            .onChanged({ value in
                if NewNode  == nil {
                    // scene -> {selectedNode}
                    // ==> scene -> {NewNode} -> {selectedNode}
                    if let nd = dragState.rotatorNode {
                        if let geom = nd.geometry {
                            geom.materials.append(otherMaterial)
                            otherMaterial = geom.materials.removeFirst()
                        }
                        if let parent = nd.parent {
                            let nn = SCNNode()
                            NewNode = nn
                            
                            nn.transform = nd.transform
                            nd.transform = SCNMatrix4Identity
                            parent.replaceChildNode(nd, with: nn)
                            nn.addChildNode(nd)
                        }
                    }
                }

            })

            .onEnded { value in
                // Remove rotator node from system applying transformation to child
                // scene -> {NewNode} -> {selectedNode}
                // ==> scene -> {selectedNode}
                if let nd = NewNode {
                    NewNode = nil
                    if let child = nd.childNodes.first {
                        // Swap red away
                        if let geom  = child.geometry {
                            geom.materials.append(otherMaterial)
                            otherMaterial = geom.materials.removeFirst()
                        }
                        // apply transformation
                        let ntr = SCNMatrix4Mult(child.transform , nd.transform)
                        child.transform = ntr
                        if let parent = nd.parent {
                            parent.replaceChildNode(nd, with: child)
                        }
                    }
                }
            }

        
    }
    struct DragS {
        var state = gestureS.idle
        var dragging = false
        var rotatorNode:SCNNode? = nil
//        var oldMag = 1.0
//        var oldAngles = SCNVector3(0,0,0)
    }
    // scene -> {NewNode} -> {selectedNode}
    //
    @State var NewNode: SCNNode?
    @GestureState var dragState = DragS()


    
    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.formatted(date: .omitted, time: .standard)
            ZStack {
                SceneViewX(sview: $view,  scene: sceneViewStore.sceneObject,
                       //    pointOfView: scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil}).first,
    
                    options: [
    //                    .allowsCameraControl,
                        .autoenablesDefaultLighting,
                        .temporalAntialiasingEnabled
                        ]
                      )
                VStack() {
                    Spacer()
                    HStack() {
                        Text( "Run: \( now) ")
                        Spacer()
                        Text( NewNode?.childNodes.first?.name ?? "")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .gesture(dragGesture)
        }
    }
}
