//
//  ContentView.swift
//  test1
//
//  Created by Thilo Jeremias on 04.11.21.
//

import SwiftUI
import SceneKit
//import AppKit
import SpriteKit
import RealityKit

fileprivate func addEditorTools(s: SCNScene)  {
    
    let redBoundingBox: SCNNode
    
//    if let top = s.rootNode.childNodes.first {
//        top.name = "toi"
//    }
    
    if let element = s.rootNode.childNodes.first {
        if  s.rootNode.childNode(withName: "MyBounding", recursively: false) != nil{
            return
        }else{
                   
            let topleft: SCNVector3 = element.boundingBox.min
             redBoundingBox = makeBBox(element)
             redBoundingBox.name = "MyBounding"
            s.rootNode.addChildNode(redBoundingBox)
            
            
            // Add arrows scaled  to scene
            let ar_a = SCNScene(named: "MyScene.scnassets/Arrows.dae")!
            
            let ar1 = ar_a.rootNode
            let bb = ar1.boundingBox
            let bw = 0.1 / (simd_float3(bb.max) - simd_float3(bb.min))

            ar1.scale = SCNVector3(bw)
            ar1.position = topleft
            ar1.position.z += 0.5
            ar1.name = "arrow"
//            redBoundingBox.addChildNode(ar1)
            s.rootNode.addChildNode(ar1)
          }
    }
}


struct viewScene: View {
    @State var scene:SCNScene
    @State var target: SCNNode
    
    init(scene: SCNScene) {
        if let bx = scene.rootNode.childNode(withName: "MyBounding", recursively: true) {
            target = bx
        } else {
        
            target = scene.rootNode.childNodes(passingTest: { node, p in node.camera != nil}).last!
        }
        self.scene = scene
    }
    // gestures
    @State private var magnification        = CGFloat(1.0)
    @State private var isDragging           = false
    @State private var totalChangePivot     = SCNMatrix4Identity
    @State private var angle                = Angle()
    @State private var box                  = SCNNode()


    var exclusiveGesture: some Gesture {
        ExclusiveGesture(drag, magnify)
        
    }
    var rotation: some Gesture {
        RotationGesture()
            .onChanged { angle in
//                self.angle = angle
                var rotationVector = SCNVector4()

                
                rotationVector.x = target.position.x
                rotationVector.y = target.position.y
                rotationVector.z = target.position.z
                rotationVector.w = angle.radians
//                let node = scene.rootNode.childNode(withName: "MyBounding", recursively: true)!
//                node.rotation = rotationVector

//                changeOrientation(of: scene.rootNode.childNode(withName: "MyBounding", recursively: true)!, with: angle.translation)

            }
            .onEnded { angle in
                print("Rot ended")
                
//                updateOrientation(of: box)
//
//                let c = scene.rootNode.childNodes(passingTest: { n,p in
//                    return n.camera != nil
//                }).first
////                let c = n.first
//                let currentPivot = c!.pivot
//                let changePivot = SCNMatrix4Invert(c!.transform)
//                totalChangePivot = SCNMatrix4Mult(changePivot, currentPivot)
//               let n = SCNMatrix4Mult(changePivot, currentPivot)
//
//                print(n)
            }
    }
    var tap: some Gesture {
        TapGesture()
            
    }
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                if !self.isDragging {
                    let hit = scnview.hitTest(value.startLocation, options: nil).first
                     
                    print(hit?.node.name)
                    target = hit?.node ?? scene.rootNode.childNodes(passingTest: { node, p in node.camera != nil}).last!
                
                self.isDragging = true
                }
                // hitTest(_ point: CGPoint,
//            options: [SCNHitTestOption : Any]? = nil) -> [SCNHitTestResult]
                changeOrientation(of: target, with: value.translation)
                
            }
            .onEnded { value in
                self.isDragging = false
                print(value.location)
                

                updateOrientation(of: target)
//                updateOrientation(of: scene.rootNode.childNode(withName: "MyBounding", recursively: true)!)
            }
    }
    @GestureState var magnifyBy = CGFloat(1.0)
    var magnify: some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { currentState, gestureState, transaction in
                            gestureState = currentState
                        }
            .onChanged{ (value) in
                self.magnification = value
                if target == nil {
                    // check if target is boundingbox or "cam"
                    
                } else {
//                print("magnify = \(self.magnification)")
                if let obj = target.camera {
                    
                        
                        changeCameraFOV(of: obj,
                                    value: self.magnification)
                        }
                    else {
//                        let mag = 1.0 //value,value,value)
                        let s = value
//                        let os = target.scale
//                        let news = SCNVector3( os.x*s,os.y*s,os.z*s)
                        target.scale = SCNVector3(s,s,s)
                        
                    }
                    }
            }
            .onEnded{ value in
                print("Ended pinch with value \(value)\n\n")
                if target.camera == nil {
                    updateOrientation(of: target)
                }
            }
    }

    
    private func updateOrientation(of node: SCNNode) {
        let currentPivot = node.pivot
        let changePivot = SCNMatrix4Invert(node.transform)
        totalChangePivot = SCNMatrix4Mult(changePivot, currentPivot)
        node.pivot = SCNMatrix4Mult(changePivot, currentPivot)
        node.transform = SCNMatrix4Identity
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

    private func changeCameraFOV(of camera: SCNCamera, value: CGFloat) {
        if self.magnification >= 1.025 {
            self.magnification = 1.025
        }
        if self.magnification <= 0.97 {
            self.magnification = 0.97
        }

        let maximumFOV: CGFloat = 25 // Zoom-in.
        let minimumFOV: CGFloat = 90 // Zoom-out.

        camera.fieldOfView /= magnification

        if camera.fieldOfView <= maximumFOV {
            camera.fieldOfView = maximumFOV
            self.magnification        = 1.0
        }
        if camera.fieldOfView >= minimumFOV {
            camera.fieldOfView = minimumFOV
            self.magnification        = 1.0
        }
    }


    // Don't forget to comment this is you are using .allowsCameraControl
   

     
//    private var scene:SCNScene {
//
//        let node=SCNNode()
//        node.position = SCNVector3(x: 0 , y: 0, z: 1)
//        node.name = "cam"
//        let cam = SCNCamera()
//        node.camera = cam
//        cam.zNear = 0.1
//        let scene = Xscene ?? SCNScene()
//        scene.rootNode.addChildNode(node)
//
//        let box = SCNBox(width: 0.5, height: 0.4, length: 0.3, chamferRadius: 0.01)
////        let boxn = SCNNode(geometry: box)
////        boxn.name="xbox"
//        self.box.geometry = box
//        self.box.name="xbox"
////        self.box.rotation = SCNVector4(x:1,y:2,z:0,w: angle.radians)
//        scene.rootNode.addChildNode(self.box)
//        return scene
//    }
//
//    @StateObject var coordinator = SceneCoordinator()
    @State var scnview: SCNView = SCNView()
    var body: some View{
//        Slider(value: $xx,in:-1...1)
        HStack{
            // Make a scene per camera
        ForEach( scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil}), id:\.self)  { n in
            SceneViewX (
                sview: $scnview,

//            SceneView(
                scene: scene,
                pointOfView: n,
                options: [
    //                .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                    ]
    //            , delegate: coordinator
                )
                .gesture(tap)
                .gesture(exclusiveGesture)
                .gesture(rotation)


    }
        }
    }
}

//class SceneCoordinator: NSObject, SCNSceneRendererDelegate, ObservableObject {
//    func renderer(_ renderer: SCNSceneRenderer,
//            didRenderScene scene: SCNScene,
//                    atTime time: TimeInterval) {
//       // print("Render..")
//    }
//}

struct BoundBoxEditorView: View {

    @State var myscene: SCNScene
    @State var scale = SCNVector3(1,1,1)
    @State var center = SCNVector3(0,0,0)
    @Binding var boundingBox: BoundingBox?
    @State var cam1: SCNCamera = SCNCamera()

    var scene: SCNScene {
        let s = myscene
        addEditorTools(s: s)

        // position bounding box
        let bbx = s.rootNode.childNode(withName: "MyBounding", recursively: false)!
            bbx.position = center
            bbx.scale = scale
            let sim_scale = simd_float3(scale)
            let sim_center = simd_float3(center)
//            boundingBox = BoundingBox(min: sim_center - sim_scale/2, max: sim_center + sim_scale/2)
        
        // position arrows
        if let ar = s.rootNode.childNode(withName: "arrow", recursively: false ) {
            let bl =  simd_float3(bbx.position) -
                (simd_float3(bbx.boundingBox.max) - simd_float3(bbx.boundingBox.min))/2.0
            ar.position = SCNVector3(bl)

        }
        return s

    }
    var bbox: SCNNode? {
        if let bbx = scene.rootNode.childNode(withName: "MyBounding", recursively: false) {
            let bb  = bbx.boundingBox
            let pw = (simd_float3(bb.max) - simd_float3(bb.min)) * simd_float3(bbx.scale)
            let pori = bbx.position
            let bx2 = SCNBox(width: CGFloat(pw.x), height: CGFloat(pw.y), length: CGFloat(pw.z), chamferRadius: 0.3)
            bx2.materials.first?.diffuse.contents = CGColor(red: 0, green: 0, blue: 1, alpha: 1)
            let nx2 = SCNNode(geometry: bx2)
            nx2.position = pori
            return nx2
        }
        return nil
            
    }
    var body: some View {
        VStack{
//            HStack {
//
//                Slider(value: $cam1.zNear, in:0 ... 2).background(.red)
//                Slider(value: $scale.y, in:0 ... 2).background(.blue)
//                Slider(value: $scale.z, in:0 ... 2).background(.green)
//            }
            HStack {
                Spacer()
//                Slider(value: $center.x, in:-1 ... 1).background(.red)
//                Slider(value: $center.y, in:-1 ... 1).background(.blue)
//                Slider(value: $center.z, in:-1 ... 1).background(.green)
                Button("X") {
                    if let bbx = bbox {
                     scene.rootNode.addChildNode(bbx)
                    print(bbx.position)
                    }
                }
            }
            viewScene(scene: scene)
//            SceneView(
//                scene: scene,
//                pointOfView: scene.rootNode.childNode(withName: "cam", recursively: true),
//                options: [
//                    .allowsCameraControl,
//                    .autoenablesDefaultLighting,
//                    .temporalAntialiasingEnabled
//                    ]
//                )
        }
    }

}

struct BoundingView: View {
    @State var scene: SCNScene
//    @State var boundingBox: BoundingBox?
    @State var object: SCNNode?
    
    
    init() {
        let objscene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
        let obj = objscene.rootNode
        let sc = SCNScene()
        
        obj.name = "Object"
        sc.rootNode.addChildNode(obj)

//        let pos = SCNVector3(1,0,0)
        let cm = SCNCamera()
        for camno in 0 ... 0 {
            
            
            let cmn = SCNNode()
            
            cmn.camera = cm
            cmn.name =  "cam" + String(camno)
            cmn.transform = SCNMatrix4MakeRotation(CGFloat(camno),1,1,1)
            cmn.position = SCNVector3(0,0,2)

            sc.rootNode.addChildNode(cmn)
        }
        
//        let bx = SCNBox(width: 0.3, height: 0.4, length: 0.5, chamferRadius: 0.03)
//        let bnx = SCNNode(geometry: bx)
//        bnx.name = "xbox"
//        sc.rootNode.addChildNode(bnx)
        
        
        scene = sc
    }
    @State var boundingBox: BoundingBox? = BoundingBox()
//    @Binding var cam:SCNNode
    
    var body: some View {
        BoundBoxEditorView(myscene: scene,boundingBox: $boundingBox)
        HStack  {
            let c=scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil})
            Text("C:  Count: \(c.count)")
            Button("Y") {
                let c=scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil})
                let n=scene.rootNode.childNodes
                for n in n {
                    print("N:\(n.name ?? " -- ") -> \(n.position)  -> \(n.rotation)")
                }
                print("Camera count: \(c.count)")
        }
        }
  }
}

#if false
struct ContinousResizingOk_Previews: PreviewProvider {
    @State static var scene: SCNScene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
    @State static var boundingBox: BoundingBox? = BoundingBox()
    static var previews: some View {
        BoundBoxEditorView(myscene: scene,boundingBox: $boundingBox)
    }
}

#endif


