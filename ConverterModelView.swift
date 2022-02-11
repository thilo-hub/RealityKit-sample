import SceneKit
import SwiftUI
import RealityKit

fileprivate func makeBBox(_ bbox: Binding<Request.Geometry?>, _ model: SCNNode) {
    let bb:BoundingBox
    if let cbn = bbox.wrappedValue?.bounds {
        bb = cbn
    }else{
        let bo = model.boundingBox
        
        bb = BoundingBox(min: SIMD3(bo.min), max: SIMD3(bo.max))
    }
    let bbx = SCNBox(width: CGFloat(bb.max.x-bb.min.x), height: CGFloat(bb.max.y-bb.min.y), length: CGFloat(bb.max.z-bb.min.z), chamferRadius: 0.01)
    let bbn = SCNNode(geometry: bbx)
    if let transform = bbox.wrappedValue?.transform.matrix {
        bbn.simdTransform = transform
    }
    
    bbx.firstMaterial?.diffuse.contents = CGColor(red: 0, green: 0, blue: 1, alpha: 0.5)
    bbn.name = "BBox"
    model.addChildNode(bbn)
}

fileprivate func cameraManipulator(camera: SCNNode,loc: SIMD2<Float>?,mag: CGFloat?,angle: Angle?) {
    if let loc = loc {

        // Dragging / Camera rotation
        let y = loc[1] * .pi
        let x = loc[0] * .pi
        camera.simdEulerAngles = simd_float3(y,x,0)
    }
    if let angle = angle?.radians {
        // rotation
        camera.simdRotation = simd_float4(0,0,-1,Float(angle))
    }
    // Magnification/Wor
    if let value = mag {
        let value = Float(value)
        camera.simdTransform[0,0] = value
        camera.simdTransform[1,1] = value
        camera.simdTransform[2,2] = value
    }
}
fileprivate func rotateObj(_ value: DragGesture.Value, viewframe: CGRect) -> SIMD2<Float> {
    // Dragging
    let hy1 = 1 * Float(value.translation.height/viewframe.height)
    let wx1 = 1 * Float(value.translation.width/viewframe.width)
    let hy = sin(hy1)
    let wx = sin(wx1)
    return SIMD2<Float>(wx,hy)
}


struct ConverterModelView: View {
    @State var model: SCNNode = SCNNode()
    @State var scene: SCNScene = SCNScene()

    @State var camera: SCNNode
    @State var world: SCNNode = SCNNode()
    @State var nview: SCNView = SCNView()
    
     init( bbox: Binding<Request.Geometry?>,modelurl: URL) {
        if let scene = try? SCNScene(url: modelurl, options: nil) {
            let model = scene.rootNode
            if bbox.wrappedValue != nil &&  model.childNode(withName: "BBox", recursively: true) == nil {
                makeBBox(bbox, model)
            }
            self.model = model
            self.scene = scene
        }
  
        let cam = SCNNode()
        cam.camera = SCNCamera()
        cam.position = SCNVector3(0,1,2)
        self.camera = cam
 
//        self.gestures = Manipulator(nview:nview,world: world)
    }
    
    
    struct GState {
        var initialized = false
        var object: SCNNode?
        var locationOffset = SIMD3<Float>(0,0,0)
        var normal = simd_float3(0,0,0)
        var quatf = simd_quatf()
        var rotmat = simd_float3x3()
    }

     @GestureState var gstate = GState()
    
    var theGestures: some Gesture {
                            SimultaneousGesture(
                                DragGesture(minimumDistance: 0) ,
                            SimultaneousGesture(
                                RotationGesture(),
                                MagnificationGesture(minimumScaleDelta: 0)
                                )
                            )
        .onEnded(){ value in
            if let bbx = world.childNode(withName: "BBox", recursively: true) {
                let bb = bbx.boundingBox
                let tx = bbx.simdTransform
//                converter.boundingBox?.transform.matrix = tx
//                converter.boundingBox?.bounds.min = SIMD3(bb.min)
//                converter.boundingBox?.bounds.max = SIMD3(bb.max)
                
            }
            if let mrk = world.childNode(withName: "Marker", recursively: true) {
                mrk.removeFromParentNode()
            }
        }
//        .onChanged(){ values in
//        }
        .updating($gstate) { values, state, trans in
            guard state.initialized else {
                guard let value = values.first else {
                    print("unexpected")
                    return
                }
                let hit = nview.XhitTest(value.startLocation, options: [:])
                let object: SCNNode
                if let hitnode = hit.first {
                    if hitnode.node.name == "BBox" {
                        // Chenge object
                        object = hitnode.node
                        normalizeNode(object)  // set pivot to identity
    //                    updateOrientation(of: object) // set transform to identity
                        let normal = hitnode.simdLocalNormal
                        let cp = simd_cross(SIMD3<Float>(0,0,1),normal)
                        let an = acos(simd_dot( SIMD3<Float>(0,0,1) , normal))
                        state.quatf  = simd_quatf(angle: an, axis: cp).normalized
                        let origNormal = normal
                        state.normal = normal
                        let cp1 = simd_cross(SIMD3<Float>(0,0,1),origNormal)
                        let an1 = acos(simd_dot( SIMD3<Float>(0,0,1) , origNormal))
                        state.rotmat = matrix_float3x3(simd_quatf(angle: an1, axis: cp1).normalized)
                        state.locationOffset = object.simdPosition
                        let ar = addArrow(scene: nview.scene!, location: hitnode.localCoordinates, maxlen: 0.25)
                        ar.simdWorldOrientation = state.quatf
//                        ar.simdPosition = state.locationOffset
                        object.addChildNode( ar )
                    } else {
                        object = world
                        updateOrientation(of: object)
                    }
                } else {
                    // Chenge camera
                    object = world
                    updateOrientation(of: object) // set transform to identity

                }

                state.object = object
                state.initialized = true
                return
            }

            guard let object = state.object else {
                return
            }
            let loc: SIMD2<Float>?
            if let value = values.first {
                loc = rotateObj(value,viewframe: self.nview.frame)
            } else {
                loc = nil
            }
            let a = values.second?.first
            let v = values.second?.second
            if object == world {
                cameraManipulator(camera: world, loc: loc, mag: v, angle: a)
            } else {
                if let loc = loc {
                    let ov = SIMD3<Float>(loc[0],-loc[1],0) * 20.0
                    let r = state.quatf.act(ov)
                    object.simdPosition = r + state.locationOffset
                }

                if let value = a {
                    // rotation
                    let angle = Float(value.radians)
                    let vec = state.normal
//                    object.simdRotation = simd_float4(vec+object.simdPosition,angle)
//                    object.simdPivot[0,3] = scaleVector[0]
//                    object.simdPivot[1,3] = scaleVector[1]
//                    object.simdPivot[2,3] = scaleVector[2]
                    
//                    Correct:
//                    object.pivot = SCNMatrix4MakeRotation(CGFloat(angle), CGFloat(vec.x), CGFloat(vec.y), CGFloat(vec.z))
                    object.pivot = SCNMatrix4MakeRotation(CGFloat(angle), CGFloat(vec.x), CGFloat(vec.y), CGFloat(vec.z))
                }

                if let value = v {
                    // Magnification/Wor
                    let value = Float(value)
                    let scaleVector = state.rotmat * SIMD3<Float>(value,value,1)
//                    object.simdRotate(by: state.quatf, aroundTarget: SIMD3<Float>(value,value,0))
//                    object.simdScale = scaleVector
//                    object.simdTransform[0,0] = 0.5
//                    object.simdTransform[1,1] = 0.5
//                    object.simdTransform[2,2] = 0.5
                    object.simdPivot[0,0] = scaleVector[0]
                    object.simdPivot[1,1] = scaleVector[1]
                    object.simdPivot[2,2] = scaleVector[2]
                }
            }
        }
    }
    func dmp( nd: SCNNode, lvl:Int){
        print(String(lvl)+": "+nd.who)
        nd.children?.forEach({
            cn in
            dmp(nd: cn,lvl: lvl+1)
        })
    }


    fileprivate func reHookNodes(_ root: SCNNode) {
        if let w = root.childNode(withName: "MyRoot", recursively: true) {
            world = w.parent!
        } else {
            let newRoot = SCNNode()
            newRoot.name = "MyRoot"
            for node in root.childNodes {
                node.removeFromParentNode()
                newRoot.addChildNode(node)
            }
            root.addChildNode(newRoot)
            world = root
        }
    }
    
    fileprivate func fixCamera(_ root: SCNNode) {
        // stupid
        var camz: CGFloat = 20.0;
        if let w = root.childNode(withName: "BBox", recursively: true) {
            let mx = w.boundingBox.max
            let mn = w.boundingBox.min
            //let k = mx + mn
            print(mx,mn)
            print(w.description)
            
            camz = mx.x - mn.x
            if camz < 0 {
                camz *= -1
            }
        }
        
        let cam = camera.camera!
        cam.focalLength = 80
        camz = (root.boundingBox.max.y-root.boundingBox.min.y) * cam.focalLength / cam.sensorHeight
        
        self.camera.position = SCNVector3(0,0,2*camz + root.boundingBox.max.z)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Button("Dump") {
                dmp(nd: scene.rootNode,lvl:1)
                dmp(nd: camera,lvl:100)
            }
            SceneViewX(sview: $nview, //$sceneViewStore.view,
               pointOfView: self.camera,
                options: [
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                    ]
                  )
//                .gesture(gestures.dragGesture)
             .gesture(theGestures)
             .onAppear(perform: {
                 nview.scene = scene
                     // make hook in new rootnode and hook all elements onto it
                     if let root = nview.scene?.rootNode {
                         reHookNodes(root)
                         fixCamera(root)
                     }
                 })

        }
    }
    
}
