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
    @State var cam: SCNNode
    @State var target: SCNNode
    @State private var boxOrig: SCNMaterial
    let redBox: SCNMaterial

    var mouseLocation: NSPoint { NSEvent.mouseLocation }
    @State var mouse: CGPoint?
//    @State var mousee: CGPoint?
    @State var overImg = false
    @State var modcam = true
    
    init(scene: SCNScene) {
        
        redBox = SCNMaterial()
        redBox.diffuse.contents = CGColor(red: 1.0, green: 0, blue: 0, alpha: 0.6)
        let bx = scene.rootNode.childNode(withName: "MyBounding", recursively: true)!
        target = bx
        boxOrig = (bx.geometry?.firstMaterial)!
        let cx = scene.rootNode.childNodes(passingTest: { node, p in node.camera != nil}).last!
        cam = cx
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
                    if scnview.hitTest(value.startLocation, options: nil).first != nil{
                        modcam = false
                        target.geometry?.materials[0] = redBox
                    } else {
                        modcam = true
                    }
                self.isDragging = true
                }
                
                changeOrientation(of: modcam ? cam : target, with: value.translation)

            }
            .onEnded { value in
                self.isDragging = false
                if !modcam {
                    target.geometry?.materials[0] = boxOrig
                }
                print(value.location)
                

                updateOrientation(of: modcam ? cam : target)
            }
    }
    @GestureState var magnifyBy = CGFloat(1.0)
    var magnify: some Gesture {
        MagnificationGesture()
            .onChanged{ (value) in
                if !self.isDragging {
                    if let mousee = mouse {
                        modcam = scnview.hitTest(mousee, options: nil).first == nil
                    }
                    print(modcam,mouse)
                    if !modcam {
                        target.geometry?.materials[0] = redBox
                    }
                    self.isDragging = true
                }
                
                self.magnification = value
                if modcam {
                    changeCameraFOV(of: cam.camera!, value: value)
                } else {
                    target.scale = SCNVector3(value,value,value)
                }
            }
            .onEnded{ value in
                print("Ended pinch with value \(value)\n\n")
                if !modcam {
                    target.geometry?.materials[0] = boxOrig
                    updateOrientation(of: target)
                }
                self.isDragging = false
                modcam = true
                
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
        let nl = camera.focalLength * value
        if nl < 100 {
            camera.focalLength = nl
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
                .onHover { over in
                                overImg = over
                            }
                            .onAppear(perform: {
                                NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
                                    if overImg {
                                        
//                                        mouse = self.mouseLocation
                                        mouse = $0.locationInWindow

                                    }
                                    return $0
                                }
                            })

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


