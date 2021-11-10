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
            cam =  cameraNode
    }
    var body: some View {
        
        HStack{
//            CamNotResetView(mycam:$cam)
            BoundingView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
