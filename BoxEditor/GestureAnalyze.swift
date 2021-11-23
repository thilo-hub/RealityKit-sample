//
//  GestureAnalyze.swift
//  RealityKit-Sample
//
//  Created by Thilo Jeremias on 23.11.21.
//

import SwiftUI
import SceneKit

struct GestureAnalyze: View {
    @EnvironmentObject var sceneViewStore: SceneData
    @State var view: SCNView
    init()
    {
        let view = SCNView()
        self.view = view
    }
    
    var body: some View {
        ZStack {
            SceneViewX(sview: $view,  scene: sceneViewStore.sceneObject,
                   //    pointOfView: scene.rootNode.childNodes(passingTest: {node,p in node.camera != nil}).first,

                options: [
//                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                    ]
                  )
            VStack() {
                Spacer()
                HStack() {
//                  Text( "Run: \( now) ")
                    Spacer()
                    Text( "Running...")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//        .gesture(dragGesture)
    }
}

struct GestureAnalyze_Previews: PreviewProvider {
    static var previews: some View {
        GestureAnalyze()
    }
}
