//
//  Shared
//
//  Created by Thilo Jeremias on 21.11.21.
//

import SwiftUI
import SceneKit
// import ViewTests

enum gestureS {
    case idle
    case cameraZoom
    case cameraMove
    case objectZoom
    case objectMove
    case objectRotate
}

let url = URL(fileURLWithPath: "/Users/thilo/Downloads/File.scn")
struct BoxEditorView: View {
    @EnvironmentObject var sceneViewStore: SceneData
    // @State var scene: SCNScene
//    @State var view: SCNView
    let selectedSurface = CGColor(red: 1, green: 0, blue: 0, alpha: 0.8)
    let defaultSurface = CGColor(red: 0, green: 0, blue: 1, alpha: 0.8)
    @State var otherMaterial = SCNMaterial()
    init()
    {
//        let view = SCNView()
//        self.view = view
//        view.scene = sceneViewStore.sceneObject
        otherMaterial.diffuse.contents = CGColor(red: 1, green: 0, blue: 0, alpha: 0.8)
        otherMaterial.isDoubleSided = true
    }
    
    let mindist = 0.0
    var dragGesture: some Gesture {
        SimultaneousGesture( DragGesture( minimumDistance: mindist), MagnificationGesture())
            .updating($dragState) { values, state, transaction in
                
//                print(".", terminator: "")
                switch state.state {
                    case .idle:
                        if let value = values.first {
                            let hit = sceneViewStore.view.XhitTest(value.startLocation, options: [:])
                            if !hit.isEmpty {
                                state.state = .objectRotate
                                state.node = hit.first!.node
//                                state.node!.geometry?.materials[0].diffuse.contents = selectedSurface
                                state.oldAngles = state.node!.eulerAngles
                                print("Object")
                            } else if let cam = sceneViewStore.sceneObject.rootNode.childNode(withName: "camera", recursively: true) {
                                state.state = .cameraMove
                                // let cam = scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil}).first {
                                    state.node = cam
                                    print("camera")
                                }
                        } else if values.second != nil {
                            state.state = .cameraZoom
                        }
                    case .cameraZoom:
                        if let cam = sceneViewStore.sceneObject.rootNode.childNodes(passingTest: {node,p in node.camera != nil}).first {
                            if let value = values.second {
                                let nv = cam.camera!.fieldOfView * state.oldMag / value
                                if 0.7 < nv && nv < 500 {
                                        cam.camera?.fieldOfView = nv
                                        state.oldMag = value
                                } else {
                                    print("Zoom limit")
                                }
    
                            }
                        }

                    case .cameraMove:
                    if values.second != nil {
                            state.state = .cameraZoom
                        } else {
                            if let value = values.first {
                                let w = 2 * .pi  * value.translation.height/self.sceneViewStore.view.frame.height
                                let h = 2 * .pi  * value.translation.width/self.sceneViewStore.view.frame.width
                                state.node!.eulerAngles = SCNVector3( w , h  , 0)
                            }
                        }
                    case .objectZoom:
                        if let node = state.node {
                            if let value = values.second {
                                node.scale = SCNVector3(x:value,y:value,z:value)
                            }
                        }
                case .objectRotate, .objectMove:
                        if let node = state.node {
                            if let value = values.first {
                                let w = 2 * .pi  * value.translation.height/self.sceneViewStore.view.frame.height
                                let h = 2 * .pi  * value.translation.width/self.sceneViewStore.view.frame.width
                                var vec = state.oldAngles
                                vec.x += w
                                vec.y += h
                                node.eulerAngles = vec

                            }
                        }
                    }
            }
            .onChanged({ value in
                if SelectedNode  == nil {
                    SelectedNode = dragState.node
                    if let nd = SelectedNode {
                        if nd.name != "camera" {
                            if let orig = nd.geometry?.materials.removeFirst() {
                                nd.geometry?.materials.insert( otherMaterial, at:0 )
                                otherMaterial = orig
                            }
                        } else {
                            print( nd.eulerAngles)
                        }
                    }
                }
            })

            .onEnded { value in
                if let nd = SelectedNode {
                    if nd.name == "camera" {
                        
                        let ntr = SCNMatrix4Mult(nd.childNodes.first!.transform , nd.transform)
                        nd.childNodes.first?.transform = ntr
//                        nd.childNodes.first?.simdTransform = ntrans
//                        print( nd.childNodes.first?.eulerAngles)
                        
                        nd.transform = SCNMatrix4Identity
                    } else {
//                        nd.geometry?.materials[0].diffuse.contents = defaultSurface
                        
                        if let orig = nd.geometry?.materials.removeFirst() {
                            nd.geometry?.materials.insert( otherMaterial, at:0 )
                            otherMaterial = orig
                        }
                        
                        
//                        updateOrientation(of: nd)
                    }
                    SelectedNode = nil
                }
//                print("onEnded", dragState.node?.debugDescription)
            }

        
    }
    struct DragS {
        var state = gestureS.idle
        var dragging = false
        var node:SCNNode? = nil
        var oldMag = 1.0
        var oldAngles = SCNVector3(0,0,0)
    }
    @State var SelectedNode: SCNNode?
    @GestureState var dragState = DragS()


    
    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.formatted(date: .omitted, time: .standard)
//            let myAngle = now.remainder(dividingBy: 10)*36
            ZStack {
                SceneViewX(sview: $sceneViewStore.view,
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
                        Text( SelectedNode?.name ?? "")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .gesture(dragGesture)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BoxEditorView()
    }
}
