//
//  SceneViewXios.swift
//  RealityKit-Sample
//
//  Created by Thilo Jeremias on 18.11.21.
//

import Foundation
import SwiftUI
import SceneKit

extension SCNView {
     func XhitTest(_ point: CGPoint, options: [SCNHitTestOption : Any]? = nil) -> [SCNHitTestResult] {
//        let hitp = CGPoint(x:point.x,y:self.frame.height-point.y)
        let b=self.hitTest(point,options: options)
//        let b=self.hitTest(hitp,options: options)
//        print("X")
        return b
    }
}

struct SceneViewX: UIViewRepresentable {
     
        private let sceneview: Binding<SCNView>
     
        func makeUIView(context: Context) -> SCNView {
            return self.sceneview.wrappedValue
        }

        func updateUIView(_ uiView: SCNView, context: Context) {
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject {
            var parent: SceneViewX
            var lastLoadedString = ""

            init(_ parent: SceneViewX) {
                self.parent = parent
            }
        }
        init(sview scn: Binding<SCNView>, scene: SCNScene? = nil, pointOfView: SCNNode? = nil, options: SceneView.Options = [], preferredFramesPerSecond: Int = 60, antialiasingMode: SCNAntialiasingMode = .multisampling4X, delegate: SCNSceneRendererDelegate? = nil, technique: SCNTechnique? = nil) {
    //    init(svgString: Binding<String>,scn: Binding<SCNView>) {
            let myview = scn.wrappedValue // SCNView()
            
            if pointOfView != nil {
                myview.pointOfView = pointOfView
            }
            if options.contains(SceneView.Options.allowsCameraControl) {
                myview.allowsCameraControl = true
            }
            if options.contains(SceneView.Options.rendersContinuously) {
                myview.rendersContinuously = true
            }
            if options.contains(SceneView.Options.autoenablesDefaultLighting) {
                myview.autoenablesDefaultLighting = true
            }

            myview.scene = scene
            myview.delegate = delegate
            myview.technique = technique
            myview.antialiasingMode = antialiasingMode
            myview.preferredFramesPerSecond = preferredFramesPerSecond
     

            self.sceneview = scn

        }
    }

   
