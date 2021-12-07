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
    
    
    if let element = s.rootNode.childNodes.first {
        if  s.rootNode.childNode(withName: "MyBounding", recursively: false) != nil{
            return
        }else{
                   
            let topleft: SCNVector3 = element.boundingBox.min
             redBoundingBox = makeBBox(element)
             redBoundingBox.name = "MyBounding"
            s.rootNode.addChildNode(redBoundingBox)
            
            
            // Add arrows scaled  to scene
//            let ar_a = SCNScene(named: "MyScene.scnassets/ship.scn")!

            let ar_a = SCNScene(named: "MyScene.scnassets/Arrows.scn")!
            
            let ar1 = ar_a.rootNode
            let bb = ar1.boundingBox
            let bw = 0.1 / (simd_float3(bb.max) - simd_float3(bb.min))

            ar1.scale = SCNVector3(bw)
            
            ar1.position = topleft
            ar1.position.z += 0.5
            ar1.name = "arrow"
            s.rootNode.addChildNode(ar1)
          }
    }
}
//private func updateOrientation(of node: SCNNode) {
//    let currentPivot = node.pivot
//    let changePivot = SCNMatrix4Invert(node.transform)
////    totalChangePivot = SCNMatrix4Mult(changePivot, currentPivot)
//    node.pivot = SCNMatrix4Mult(changePivot, currentPivot)
//    node.transform = SCNMatrix4Identity
//}

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
    if nl < 100 && nl > 1 {
        camera.focalLength = nl
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

    @State var overImg = false
    @State var modcam = true
    
    init(scene: SCNScene) {
        
        redBox = SCNMaterial()
        redBox.diffuse.contents = CGColor(red: 1.0, green: 0, blue: 0, alpha: 0.6)
        let bx = scene.rootNode.childNode(withName: "MyBounding", recursively: true)!
        target = bx
        boxOrig = (bx.geometry?.firstMaterial)!
        if let cx = scene.rootNode.childNodes(passingTest: { node, p in node.camera != nil}).last {
        cam = cx
        } else {
            let camc = SCNCamera()
            let camn = SCNNode()
            camn.camera = camc
            cam = camn
        }
        
        self.scene = scene
        self.scnview.scene = scene
        
    }
    
    // gestures
    @State private var magnification        = CGFloat(1.0)
    @State private var isDragging           = false
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
                
            }
    }
    var locString : String {
            guard let loc = tapLocation else { return "Tap" }
            return "\(Int(loc.x)), \(Int(loc.y))"
        }
    @State var tapLocation: CGPoint?
    var tap: some Gesture {
        TapGesture()
            .onEnded{ value in
                 tapLocation = dragLocation
            print("Tapped: \(locString)")
        }
    }
    @State var dragLocation: CGPoint?
       
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                if !self.isDragging {
                    let tgt = scnview.XhitTest(value.startLocation, options: [.searchMode:1])
                    if  tgt.count > 0 {
                        print(tgt)
                        
                        modcam = false
                        target.geometry?.materials[0] = redBox
                    } else {
                        modcam = true
                    }
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
                        modcam = scnview.XhitTest(mousee, options: nil).first == nil
                    }
//                    print(modcam,mouse)
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
    
   

    @State var scnview: SCNView = SCNView()
    var body: some View{

        HStack{
            
            // Make a scene per camera
            ForEach( scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil}), id:\.self)  { n in
            SceneViewX (
                sview: $scnview,
//                scene: scene,
                pointOfView: n,
                options: [

                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                    ]
                )
                
//                .gesture(tap)
//                .gesture(drag)
            
                .gesture(exclusiveGesture)
                .gesture(rotation)
                
                // Check if there is a better way..
                .onHover { over in
                                overImg = over
                            }
                            .onAppear(perform: {
                                updateOrientation(of: cam)
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



struct BoundBoxEditorView: View {

    @State var myscene: SCNScene
//    @State var scale = SCNVector3(1,1,1)
//    @State var center = SCNVector3(0,0,0)
    @Binding var boundingBox: BoundingBox?
    @State var cam1: SCNCamera = SCNCamera()

    var scene: SCNScene {
        let s = myscene
        addEditorTools(s: s)

        // position bounding box
        let bbx = s.rootNode.childNode(withName: "MyBounding", recursively: false)!
        
        // position arrows
        if let ar = s.rootNode.childNode(withName: "arrow", recursively: false ) {
            let bl =  simd_float3(bbx.position) -
                (simd_float3(bbx.boundingBox.max) - simd_float3(bbx.boundingBox.min))/2.0
            ar.position = SCNVector3(bl)
            updateOrientation(of: ar)
        }
        return s

    }
    // Dumplicate current bounding box -- DEBUG
    var BigRoundBox: SCNNode? {
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
            HStack {
                Spacer()
                Button("X") {
                    if let bbx = BigRoundBox {
                     scene.rootNode.addChildNode(bbx)
                    print(bbx.position)
                    }
                }
            }
            viewScene(scene: scene)
        }
    }

}

struct BoundingView: View {
    @State var scene: SCNScene
//    @State var boundingBox: BoundingBox?
    @State var boundingBox: BoundingBox? = BoundingBox()

    @State var object: SCNNode?
    
   // @EnvironmentObject
    
    init() {
        let objscene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
        let obj = objscene.rootNode
        let sc = SCNScene()
        
        obj.name = "Object"
        sc.rootNode.addChildNode(obj)

        let cm = SCNCamera()
 
        for camno in 0 ... 0 {
            
            let cmn = SCNNode()

            cmn.camera = cm
            cmn.name =  "cam" + String(camno)
            cmn.transform = SCNMatrix4MakeRotation(CGFloat(camno),1,1,1)
            cmn.position = SCNVector3(0,0,2)

            sc.rootNode.addChildNode(cmn)
        }
        
        scene = sc
    }

    
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
    @StateObject static var sceneObject: SCNScene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
    @StateObject static var boundingBox: BoundingBox? = BoundingBox()
    static var previews: some View {
        BoundBoxEditorView(myscene: sceneObject,boundingBox: $boundingBox)
            .environmentObject(sceneObject)
            
    }
}

#endif


