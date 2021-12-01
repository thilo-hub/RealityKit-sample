//
//  ContentView.swift
//  hittest
//
//  Created by Thilo Jeremias on 18.11.21.
//

import SwiftUI
import SceneKit
//
//  SceneviewX.swift
//  RealityKit-Sample (iOS)
//
//  Created by Thilo Jeremias on 15.11.21.
//


let box_name = "Box"
//private func updateOrientation(of node: SCNNode) {
//    let currentPivot = node.pivot
//    let changePivot = SCNMatrix4Invert(node.transform)
//    node.pivot = SCNMatrix4Mult(changePivot, currentPivot)
//    node.transform = SCNMatrix4Identity
//}

fileprivate func createScene() -> SCNScene {
    let sc = SCNScene() // named:"MyScene.scnassets/Arrows.dae")!
//    sc.backgrou
    sc.background.contents = Color.clear //Color.clear // NSColor.clear
    let camn = SCNNode()
    let cam  = SCNCamera()
    camn.camera = cam
    camn.name = "camera"
    camn.position = SCNVector3(0,4,20)
    sc.rootNode.addChildNode(camn)

    
    let plane  = SCNPlane(width: 20,height: 20)
    plane.materials[0].diffuse.contents = CGColor(red: 0, green: 0, blue: 1, alpha: 0.5)
    plane.materials[0].isDoubleSided = true

    let planen = SCNNode(geometry: plane)
    planen.position = SCNVector3(0,0,0)
    planen.rotation = SCNVector4(x: 1, y: 0, z: 0, w: .pi / -2.0)
    planen.name = "plane"
    sc.rootNode.addChildNode(planen)
    
    let box  = SCNBox(width: 5, height: 7, length: 9, chamferRadius: 0.5)
    let boxn = SCNNode(geometry: box)
    boxn.name = box_name
    sc.rootNode.addChildNode(boxn)
    
    
//    updateOrientation(of: camn)

    return sc
}
struct ContentView: View {
    @State var scnview = SCNView()
    @State var scene: SCNScene = createScene()
    @State var oldn: [SCNNode] = []
    
    fileprivate func retirePaintBalls() {
        if oldn.count > 10 {
            let dn = oldn.removeFirst()
            dn.removeFromParentNode()
        }
        oldn.forEach({node in node.simdScale = node.simdScale * 0.8})
    }
    
    fileprivate func makePaintBalls(_ target: SCNHitTestResult) {
        let ball  = SCNSphere(radius: 0.6)
        let balln = SCNNode(geometry: ball)
        oldn.append(balln)
        balln.position = target.localCoordinates
        scene.rootNode.addChildNode(balln)
    }
    
    fileprivate func dragEnded(_ value: DragGesture.Value) {
        print("Drag: \(value.startLocation)")
      
        let hitTestOptions:[SCNHitTestOption:Any] = [:
                                                        //                        SCNHitTestOption.sortResults : NSNumber(value: true),
                                                     //                        SCNHitTestOption.boundingBoxOnly : NSNumber(value: true)
        ]
        
        marker.append(value.startLocation)
        
        let tgt = scnview.XhitTest(value.startLocation, options: hitTestOptions)
           if  tgt.count > 0 {
            retirePaintBalls()
            
            tgt.forEach({ target in
                makePaintBalls(target)
                
            })
        }
    }
    
    var onTap: some Gesture {
        DragGesture(minimumDistance: 0) //, coordinateSpace: <#T##CoordinateSpace#>)
            .onEnded{ value in
                dragEnded(value)
                    

             }
    }
    @State var marker: [CGPoint] = [CGPoint(x:200,y:300)]
//    @State var obj = Circle()
//    @State var graph:GraphicsContext
    var body: some View {
        GeometryReader { proxy in
        ZStack {
            Canvas(){ context, size in
                for i in marker {
                    
                    let image = Image(systemName: "x.circle")
//                        .resizable(capInsets: 1, resizingMode: 1)
                
//                        .foregroundColor(.red)
                        
//                        .font(.system(size: 20, weight: .light, design: .serif))
                        
                    context.draw(image, at: i)
                }
            }
            .foregroundColor(.red)
//            .background(.red)
            
            
         SceneViewX (
            sview: $scnview,
            scene: scene,
            pointOfView: scene.rootNode.childNode(withName: "camera", recursively: false),
            options: [
//                .allowsCameraControl,
                .autoenablesDefaultLighting,
                .temporalAntialiasingEnabled
                
                ]
            )
                .background(.clear)
               
                .gesture(onTap)
//                .gesture(exclusiveGesture)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
              
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .border(Color.blue)
 
        }
    }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
