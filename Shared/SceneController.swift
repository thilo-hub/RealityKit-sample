//
//  GameViewController.swift
//  game1
//
//  Created by Thilo Jeremias on 07.11.21.
//

import SceneKit
import SwiftUI
//import QuartzCore
class tpg: NSPressGestureRecognizer {
    @objc override dynamic func mouseDragged(with event: NSEvent) {
        print("Here drag..")
    }
}


struct SceneViewController: NSViewRepresentable {
    
    var scene: SCNScene
    var options: [Any]
    @State var camera: SCNNode

    var view = SCNView()
    
    func makeNSView(context: Context) -> SCNView {
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.lightGray //darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Instantiate the SCNView and setup the scene
        view.scene = scene
        view.pointOfView = camera //scene.rootNode.childNode(withName: "camera", recursively: true)
//        view.allowsCameraControl = true
        
        // Add gesture recognizer
        let tapGesture = tpg(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        
        view.backgroundColor = .clear
        
        
        
        
        
        view.addGestureRecognizer(tapGesture)
  
        var gestureRecognizers = view.gestureRecognizers
        gestureRecognizers.insert(tapGesture, at: 0)
        view.gestureRecognizers = gestureRecognizers

        
        return view
    }
    
    func updateNSView(_ view: SCNView, context: Context) {
        print("update")
        //
    }

    func makeCoordinator() -> Coordinator {
          Coordinator(view)
      }
      
      class Coordinator: NSObject {
          private let view: SCNView
          init(_ view: SCNView) {
              self.view = view
              super.init()
          }
      
          @objc func handleTap(_ gestureRecognizer: NSGestureRecognizer) {
              print("Here X")
              
              // retrieve the SCNView
              let scnView = self.view
        

              // check what nodes are clicked
              let p = gestureRecognizer.location(in: scnView)
              let hitResults = scnView.hitTest(p, options: [:])
              // check that we clicked on at least one object
              if hitResults.count > 0 {
                  // retrieved the first clicked object
                  let result = hitResults[0]

                  let name = result.node.name
                  print(name)

                  let toi = scnView.scene?.rootNode.childNode(withName: "toi", recursively: false)
                  let toi_axis: SCNVector3?
                  switch name {
                  case "Red":
                      toi_axis  = SCNVector3(1,0,0)
                  case "Green":
                      toi_axis  = SCNVector3(0,1,0)
                  case "Blue":
                      toi_axis  = SCNVector3(0,0,1)
                  default:
                      toi_axis  = nil
                      
                  }
                  
                  
                  // get its material
                  let material = result.node.geometry!.firstMaterial!

                  
                  if let evec = toi_axis {
                      // highlight it
                      SCNTransaction.begin()
                      SCNTransaction.animationDuration = 0.5

                      // on completion - unhighlight
                      SCNTransaction.completionBlock = {
                          SCNTransaction.begin()
                          SCNTransaction.animationDuration = 0.5

                          material.emission.contents = NSColor.black
                          toi?.position = SCNVector3(0,0,0)

                          SCNTransaction.commit()
                      }
                      toi?.position = evec
                      material.emission.contents = NSColor.red

                      SCNTransaction.commit()
                  }
              }
          }
      }

}
//
//
//class NSceneViewController: NSViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // create and add a camera to the scene
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        scene.rootNode.addChildNode(cameraNode)
//
//        // place the camera
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
//
//        // create and add a light to the scene
//        let lightNode = SCNNode()
//        lightNode.light = SCNLight()
//        lightNode.light!.type = .omni
//        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
//        scene.rootNode.addChildNode(lightNode)
//
//        // create and add an ambient light to the scene
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = SCNLight()
//        ambientLightNode.light!.type = .ambient
//        ambientLightNode.light!.color = NSColor.darkGray
//        scene.rootNode.addChildNode(ambientLightNode)
//
//        // retrieve the ship node
//        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
//
//        // animate the 3d object
//        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
//
//        // retrieve the SCNView
//        let scnView = self.view as! SCNView
//
//        // set the scene to the view
//        scnView.scene = scene
//
//        // allows the user to manipulate the camera
//        scnView.allowsCameraControl = true
//
//        // show statistics such as fps and timing information
//        scnView.showsStatistics = true
//
//        // configure the view
//        scnView.backgroundColor = NSColor.black
//
//        // Add a click gesture recognizer
//        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
//        var gestureRecognizers = scnView.gestureRecognizers
//        gestureRecognizers.insert(clickGesture, at: 0)
//        scnView.gestureRecognizers = gestureRecognizers
//    }
//
//    @objc
//    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
//        // retrieve the SCNView
//        let scnView = self.view as! SCNView
//
//        // check what nodes are clicked
//        let p = gestureRecognizer.location(in: scnView)
//        let hitResults = scnView.hitTest(p, options: [:])
//        // check that we clicked on at least one object
//        if hitResults.count > 0 {
//            // retrieved the first clicked object
//            let result = hitResults[0]
//
//            // get its material
//            let material = result.node.geometry!.firstMaterial!
//
//            // highlight it
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = 0.5
//
//            // on completion - unhighlight
//            SCNTransaction.completionBlock = {
//                SCNTransaction.begin()
//                SCNTransaction.animationDuration = 0.5
//
//                material.emission.contents = NSColor.black
//
//                SCNTransaction.commit()
//            }
//
//            material.emission.contents = NSColor.red
//
//            SCNTransaction.commit()
//        }
//    }
//}
