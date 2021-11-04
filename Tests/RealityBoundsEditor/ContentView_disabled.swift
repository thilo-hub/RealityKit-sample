//
//  ContentView.swift
//  test1
//
//  Created by Thilo Jeremias on 04.11.21.
//

import SwiftUI
import SceneKit

////struct ContentView: View {
////    let scene = SCNScene(named: "MyScene.scnassets/Data5.usdz")!
////
////    var body: some View {
////        ZStack {
////
////        SceneView(
////            scene: scene,
////           // pointOfView: cameraNode,
////            options: [
////                .allowsCameraControl,
////                .autoenablesDefaultLighting,
////                .temporalAntialiasingEnabled
////            ]
////        )
////            HStack{
////            Text("Hello, world!")
////                Button("Y"){
////                    let geometry = SCNBox(width: 0.6 , height: 0.6,
////                                           length: 0.1, chamferRadius: 0.005)
////                    geometry.firstMaterial?.diffuse.contents = Color("aqua")
////                    geometry.firstMaterial?.specular.contents = Color("white")
////                    geometry.firstMaterial?.emission.contents = Color("blue")
////                    let boxnode = SCNNode(geometry: geometry)
//////
////
////                    let offset: Int = 16
////
//////                    scene.rootNode.addChildNode(boxnode)
////                    for xIndex:Int in 0...32 {
////                        for yIndex:Int in 0...32 {
////                            let boxCopy = boxnode.copy() as! SCNNode
////                            boxCopy.position.x = CGFloat(xIndex - offset)
////                            boxCopy.position.y = CGFloat(yIndex - offset)
////                            //self.
////                            scene.rootNode.addChildNode(boxCopy)
////                        }
////                    }
////
////
////
////
////                }
////            Button("X"){
////                // retrieve the ship node
////                let ship = scene.rootNode.childNode(withName: "baked_mesh", recursively: true)!
////
////                // animate the 3d object
////                ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0.1, z: 0.2, duration: 1)))
////
////            }
////            }
////        }
////            .padding()
////    }
////}
////
//
//
//struct ContentView: View {
//    @State var turn:Double = 2.5
//    @State var rot: Double = 0
//  var body: some View {
//    return VStack {
//    Image(systemName: "circle")
//      .foregroundColor(Color.blue)
//      .onTapGesture {
//        withAnimation(.linear(duration: 36)) {
//          self.turn = 720
//        }
//      }
//        MainView(turn: $turn,rot: $rot)
//    } // VStack
//  }
//}
//
//struct MainView: View {
//    @Binding var turn: Double
//    @Binding var rot: Double
//
//
//    var scene: SCNScene? {
//
//        if let rsrc = Bundle.main.url(forResource: "Data9", withExtension: "usdz", subdirectory: "MyScene.scnassets") {
//            if let s = try? SCNScene(url: rsrc) {
//
//                let bb = s.rootNode.childNode(withName: "BB", recursively: true)
//                print(bb)
//                let ball = SCNBox(width: 0.1 , height: 0.1,
//                                      length: 0.1, chamferRadius: 0.005)
//                let scnnode = SCNNode(geometry: ball)
//                let scale = turn
//                let sc = SCNVector3Make(scale,scale,scale)
//                let rc = SCNVector4Make(1,0,0,rot)
//                scnnode.scale = sc
//                scnnode.rotation = rc
//                s.rootNode.addChildNode(scnnode)
//                return s
//            }
//
//            // we found the file in our bundle!
//
//            return try? SCNScene(url: rsrc)
//        }
//        return nil
//        }
//
//    var cameraNode: SCNNode? {
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
//        cameraNode.camera?.zNear = 0.1
//        return cameraNode
//    }
//
//
//    fileprivate func makeBoxes() {
//        if let s = scene {
//            //                  let scale = turn
//            //                  let rv: SCNQuaternion = SCNQuaternion(scale,scale,scale,scale)
//            //                  let sc = SCNVector3Make(scale,scale,scale)
//
//            let offset: Int = 0
//            let geometry = SCNBox(width: 0.1 , height: 0.1,
//                                  length: 0.1, chamferRadius: 0.005)
//            //                      geometry.firstMaterial?.diffuse.contents = Color.black
//            //                      geometry.firstMaterial?.specular.contents = Color.green // Color("white")
//            //                      geometry.firstMaterial?.emission.contents = Color.blue
//            ////                      geometry.firstMaterial?.selfIllumination = Color.green
//            //                      geometry.firstMaterial?.transparency = 0.9
//            let boxnode = SCNNode(geometry: geometry)
//            //                  boxnode.rotation = rv
//            //  s.addChildNode(boxnode)
//            //                      return
//            for xIndex:Int in -2 ... 2 {
//                for yIndex:Int in -2...2 {
//                    let boxCopy = boxnode.copy() as! SCNNode
//
//                    boxCopy.position.x = CGFloat(xIndex - offset)
//                    boxCopy.position.y = CGFloat(yIndex - offset)
//                    //self.
//                    s.rootNode.addChildNode(boxCopy)
//                }
//            }
//        }
//    }
//
//    var body: some View {
//    VStack{
//        HStack {
//            Text("T:")
//            Slider(value: $turn,in: 0...10)
//            Text("R:")
//            Slider(value: $rot,in: 0...10)
//            Text("R:\(turn)")
//            Button("X"){ makeBoxes()  }
//        }
//        SceneView(
//            scene: scene,
//            pointOfView: cameraNode,
//            options: [
//                .allowsCameraControl,
//                .autoenablesDefaultLighting,
//                .temporalAntialiasingEnabled
//            ]
//        )
//
//    //    ZStack {
//    //      Circle()
//    //        .stroke(Color.red, lineWidth: 4)
//    //          .frame(width: 145, height: 145, alignment: .center)
//    //
//    //      Group {
//    //
//    //        ZStack {
//    //        Text("Center")
//    //        Ellipse()
//    //          .stroke(Color.blue, lineWidth: 4)
//    //          .frame(width: 128, height: 128, alignment: .center)
//    //        .rotation3DEffect(.degrees(turn), axis: (x: 1, y: -1, z: 0), anchor: UnitPoint.center, anchorZ: 0, perspective: 0)
//    //        Ellipse()
//    //          .stroke(Color.blue, lineWidth: 4)
//    //          .frame(width: 128, height: 128, alignment: .center)
//    //          .rotation3DEffect(.degrees(turn+90), axis: (x: -1, y: 1, z: 0), anchor: UnitPoint.center, anchorZ: 0, perspective: 0)
//    //        Ellipse()
//    //          .stroke(Color.green, lineWidth: 4)
//    //          .frame(width: 128, height: 128, alignment: .center)
//    //          .rotation3DEffect(.degrees(turn), axis: (x: 1, y: 1, z: 0), anchor: UnitPoint.center, anchorZ: 0, perspective: 0)
//    //        Ellipse()
//    //          .stroke(Color.green, lineWidth: 4)
//    //          .frame(width: 128, height: 128, alignment: .center)
//    //          .rotation3DEffect(.degrees(turn+90), axis: (x: 1, y: 1, z: 0), anchor: UnitPoint.center, anchorZ: 0, perspective: 0)
//    //        }
//    //      }
//    //      }
//
//    }
//  }
//}


struct MainView: View {
    @Binding var turn: Double
    @Binding var rot: Double
        var scene: SCNScene? {
    
            if let rsrc = Bundle.main.url(forResource: "Data9", withExtension: "usdz", subdirectory: "MyScene.scnassets") {
                if let s = try? SCNScene(url: rsrc) {
    
                    let bb = s.rootNode.childNode(withName: "BB", recursively: true)
                    print(bb)
                    let ball = SCNBox(width: 0.1 , height: 0.1,
                                          length: 0.1, chamferRadius: 0.005)
                    let scnnode = SCNNode(geometry: ball)
                    let scale = turn
                    let sc = SCNVector3Make(scale,scale,scale)
                    let rc = SCNVector4Make(1,0,0,rot)
                    scnnode.scale = sc
                    scnnode.rotation = rc
                    s.rootNode.addChildNode(scnnode)
                    return s
                }
    
                // we found the file in our bundle!
    
                return try? SCNScene(url: rsrc)
            }
            return nil
            }
    
        var cameraNode: SCNNode? {
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
            cameraNode.camera?.zNear = 0.1
            return cameraNode
        }
    

        var body: some View {
            VStack{
                HStack {
                    Text("T:")
                    Slider(value: $turn,in: 0...10)
                    Text("R:")
                    Slider(value: $rot,in: 0...10)
                    Text("R:\(turn)")
    //                Button("X"){ makeBoxes()  }
                }
                SceneView(
                    scene: scene,
                    pointOfView: cameraNode,
                    options: [
                        .allowsCameraControl,
                        .autoenablesDefaultLighting,
                        .temporalAntialiasingEnabled
                    ]
                )
            }
        }
}

//struct ContentView: View {
//    @State var turn:Double = 2.5
//    @State var rot: Double = 0
//  var body: some View {
//    return VStack {
//    Image(systemName: "circle")
//      .foregroundColor(Color.blue)
//      .onTapGesture {
//        withAnimation(.linear(duration: 36)) {
//          self.turn = 720
//        }
//      }
//        MainView(turn: $turn,rot: $rot)
//    } // VStack
//  }
//}
//
//
//struct ContentView_Previews: PreviewProvider {
//    @State static var turn:Double = 1.0
//    @State static var rot:Double = 1.0
//    static var previews: some View {
//        
//        MainView(turn: $turn,rot: $rot)
//    }
//}
//
//
