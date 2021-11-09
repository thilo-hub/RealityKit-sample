//
//  ContentView.swift
//  test1
//
//  Created by Thilo Jeremias on 04.11.21.
//

import SwiftUI
import SceneKit
import AppKit
import SpriteKit


//@objc
func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
print("here")
}

//
// Minimal view that allows a mesh (the first one) to be shown with its bounding box
// Sliders allow to adjust the box
//

struct MySceneView: View {
//    @State var myscene: SCNScene
//    var view: SCNView
    var t: SceneView
    let newGesture = TapGesture().onEnded {
            print("Tap on myscene.")
        }

    init(scene: SCNScene,options: SceneView.Options) {
        t = SceneView(scene: scene,options: options)
        let _ = t.simultaneousGesture(newGesture)
        let res = t.onLongPressGesture {
            print("Looon")
        }
        print (res)
    }
    func mytst() {
        let res = "mytest apeared"
        
//        view.onLongPressGesture(perform:
//                                    { print ("Another Long")
//
//        })
        print(res)
    }
    var body: some View {
        t.onAppear {
            mytst()
            
        }
    }
    
}

struct GlobeView: View {

    @State var myscene: SCNScene
    @State var pos = SCNVector3(0,0,0)
    @State var scale = 1.0

    var sceneArrow: SCNScene {
        // Add arrows scaled  to scene
        let ar_a = SCNScene(named: "MyScene.scnassets/Arrows.dae")!
//        let ar1 = ar_a.rootNode
//        let bb = ar1.boundingBox
//        let bw = bb.max - bb.min
//
//        ar1.scale = SCNVector3(0.1/bw.x,0.1/bw.y,0.1/bw.z)
//        ar1.position = topleft
//        s.rootNode.addChildNode(ar1)
        ar_a.background.contents = CGColor(red: 0.8, green: 0.0, blue: 0, alpha: 0.0)
  // vbackground = CGColor.clear
        return ar_a

    }
    @Binding var cam: SCNNode
    
    
    
    
    // Create scene from base scene with correct bounding box installed
//    @State var cam: SCNNode = SCNNode()
    
    var scene: SCNScene {
        let s = myscene
        
        let bbx = s.rootNode.childNode(withName: "MyBounding", recursively: true)!
            bbx.position = pos
            bbx.scale = SCNVector3(scale,scale,scale)
        
        return s

    }
    var cameraNode: SCNNode {
        let cameraNode = cam // SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0 , y: 0, z: 3)
        cameraNode.camera?.zNear = 0.1
        return cameraNode
    }
    
    @State var isDragging = false
    @State var tapped = false

     var drag: some Gesture {
//         TapGesture(count: 1)
//                     .onEnded { _ in
//                         self.tapped = !self.tapped
//                     }
         DragGesture()
             .onChanged { _ in
                 self.isDragging = true
                 
             }
             .onEnded { _ in
                 self.isDragging = false
                 
             }
     }

    let newGesture = TapGesture().onEnded {
            print("Tap on VStack.")
        }
    
    var body: some View {
        VStack{
            HStack {
                Text("Good")
                Slider(value: $scale,in: 0...10)
                Text(String(format:"R: %2.3f",scale)).frame(minWidth: 80,alignment: .topTrailing)
                Slider(value: $pos.x, in:-1 ... 1)
                Slider(value: $pos.y, in:-1 ... 1)
                Slider(value: $pos.z, in:-1 ... 1)
            }
            ZStack {
//#if false
//#else
                SceneView(
                    scene: scene,
                    pointOfView: cam,
                        options: [
                        .allowsCameraControl,
                        .autoenablesDefaultLighting,
                        .temporalAntialiasingEnabled
                        ]
                )
//                    .body.addGestureRecognizer(tpg)
                    
//                {
//                        self.body.view.addGestureRecognizer(scene)
//                        print( "Long")}
//                    .allowsHitTesting(true)
//                    .onTapGesture {
//                    print ("TAP")
//                }
//#endif
//                SceneViewController(scene: sceneArrow,
//                                    options: [
////                                    .allowsCameraControl,
////                                    .autoenablesDefaultLighting,
////                                    .temporalAntialiasingEnabled
//                                    ],
//                                    camera: cam
//                ).frame(width: 100, height: 100, alignment: .center)
                  
//                SpriteView(scene: { () -> SKScene in
//                    let scene = SKScene()
////                    scene.backgroundColor = .clear
//                    let model = SK3DNode(viewportSize: .init(width: 100, height: 100))
//                    model.scnScene = {
//                        let scene = SCNScene(named: "MyScene.scnassets/Arrows.dae")!
////                        scene.background.contents = CGColor(red: 1, green: 0, blue: 0, alpha: 0.6) //NSColor.clear
//                        let cameraNode = SCNNode()
//                        cameraNode.camera = SCNCamera()
//                        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
//                        scene.rootNode.addChildNode(cameraNode)
//                        return scene
//                    }()
//                    scene.addChild(model)
//                    return scene
//                }(), options: [.allowsTransparency])
//                    .frame(width: 100, height: 100, alignment: .center)

            }
           
//            .gesture(drag)
         }
    }
}

struct DragGestureView: View {
    @State var isDragging = false

    var drag: some Gesture {
        DragGesture()
            .onChanged { _ in self.isDragging = true }
            .onEnded { _ in self.isDragging = false }
    }

    var body: some View {
        Circle()
            .fill(self.isDragging ? Color.red : Color.blue)
            .frame(width: 100, height: 100, alignment: .center)
            .gesture(drag)
    }
}

struct ContinousResizingOkView: View {
    let scene: SCNScene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
    
//    @State var aCam: SCNNode = SCNNode()
    @Binding var cam: SCNNode
        
    var fullScene: SCNScene {
        let s = scene
        let redBoundingBox: SCNNode
        
        if let top = s.rootNode.childNodes.first {
            top.name = "toi"
        }

        
        
        if let element = s.rootNode.childNodes.first {
            
            let topleft: SCNVector3 = element.boundingBox.max
             redBoundingBox = makeBBox(element)
             redBoundingBox.name = "MyBounding"
            s.rootNode.addChildNode(redBoundingBox)
            
            
//            // Add arrows scaled  to scene
//            let ar_a = SCNScene(named: "MyScene.scnassets/Arrows.dae")!
//            let ar1 = ar_a.rootNode
//            let bb = ar1.boundingBox
//            let bw = bb.max - bb.min
//
//            ar1.scale = SCNVector3(0.1/bw.x,0.1/bw.y,0.1/bw.z)
//            ar1.position = topleft
//            s.rootNode.addChildNode(ar1)
//
//

            
        }
        else
        {
            let redBox = SCNBox(width: 0.1 , height: 0.1,
                                  length: 0.1, chamferRadius: 0.005)
            redBox.firstMaterial?.diffuse.contents = CGColor(red: 0.8, green: 0.0, blue: 0, alpha: 0.8)
            redBoundingBox = SCNNode(geometry: redBox)
        }
        
        
        
        return s
    }
    let newGesture = TapGesture().onEnded {
            print("Tap on VStack.")
        }

    var body: some View {
        GlobeView(myscene: fullScene, cam: $cam)
            .highPriorityGesture(newGesture,including: GestureMask.gesture)
  }
}


struct ContinousResizingOk_Previews: PreviewProvider {
    @State static var scene: SCNScene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
    @State static var cam: SCNNode = SCNNode()
    
    static var previews: some View {
        GlobeView(myscene: scene, cam: $cam)
    }
}


