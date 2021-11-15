//
//  ContentView.swift
//  test3
//
//  Created by Thilo Jeremias on 07.11.21.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @State var cam: SCNNode

    init() {
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0 , y: 0, z: 3)
            cameraNode.camera?.zNear = 0.1
            cameraNode.name = "cam"
            cam =  cameraNode
    }
    var body: some View {
        
        VStack{
//            CamNotResetView(mycam:$cam)
            
//            Text("C: \(cam.position) - \(cam.rotation)")
            
            BoundingView()
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
