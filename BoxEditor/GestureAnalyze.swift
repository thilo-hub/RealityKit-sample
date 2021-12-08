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
    struct Gstate {
        var dragStart: CGPoint?
        var dragSize: CGSize?
        var magnification: CGFloat?
        var rotation: CGFloat?
        
    }
    @GestureState var dragState = Gstate()
    var dragGesturedrag: some Gesture { DragGesture(minimumDistance: 0)
            .updating($dragState) { m, state, transaction in
                state.dragStart = m.startLocation
                state.dragSize  = m.translation
            }
    }

    var dragGesturerot: some Gesture { RotationGesture(minimumAngleDelta: Angle.degrees(0))
            .updating($dragState) { m, state, transaction in
                state.rotation = m.degrees
            }
    }

    var dragGesturemag: some Gesture { MagnificationGesture(minimumScaleDelta: 0)
            .updating($dragState) { m, state, transaction in
                state.magnification = m
            }
    }
    var twoGestures: some Gesture {
         SimultaneousGesture(RotationGesture(minimumAngleDelta: Angle.degrees(0)),
                             MagnificationGesture(minimumScaleDelta: 0))
            .updating($dragState) { values, state, transaction in
                if let m = values.first?.degrees {
                    state.rotation = m
                }
                if let m = values.second?.magnitude {
                    state.magnification = m
                }
            }
    }
    let agesture = DragGesture( minimumDistance: 1)
        .modifiers(.shift)
        .onChanged(){ value in
            print (value)
        }
        .onEnded(){ value in
            print(value,"ENDED")
        }
    let bgesture = DragGesture( minimumDistance: 1)
        .modifiers(.command)
        .onEnded(){ value in
            print("Ended: ",value)
        }
    var threeGestures: some Gesture {
        SimultaneousGesture( DragGesture( minimumDistance: 0),
                             SimultaneousGesture(RotationGesture(minimumAngleDelta: Angle.degrees(0)),
                             MagnificationGesture(minimumScaleDelta: 0)) )
//            .modifiers(.shift)
            .updating($dragState) { values, state, transaction in
                if let m = values.second?.first?.degrees {
                    state.rotation = m
                }
                if let m = values.second?.second?.magnitude {
                    state.magnification = m
                }
                if let ds = values.first{
                    state.dragStart = ds.startLocation
                    state.dragSize = ds.translation
                }
            }
    }
    
    @State var scale:CGFloat?
    @State var angle:Double?
    @State var view:SCNView = SCNView()
    var body: some View {
        let magnificationGesture = MagnificationGesture().onChanged { (value) in
             scale = value.magnitude
         }
         
         // 3.
         let rotationGesture = RotationGesture().onChanged { (value) in
             angle = value.degrees
         }
         
         // 4.
         let magnificationAndRotateGesture = magnificationGesture.simultaneously(with: rotationGesture)


        ZStack {
//            SceneViewX(sview: $sceneViewStore.view,
            SceneViewX(sview: $view,

                options: [
//                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                    ]
                  )
                .onAppear(perform: {view.scene = sceneViewStore.sceneObject})
            VStack() {
                HStack() {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Drag Start   : \(dragState.dragStart.debugDescription)")
                        Text("Drag Size    : \(dragState.dragSize.debugDescription)")
                        Text("Magnification: \(dragState.magnification.debugDescription)")
                        Text("Rotation     : \(dragState.rotation.debugDescription)")
                        Text("O-Rotation   : \(angle.debugDescription)")
                        Text("O-Magnificati: \(scale.debugDescription)")
                    }
                Spacer()
                }
                Spacer()
                HStack() {
//                  Text( "Run: \( now) ")
                    Spacer()
                    Text( "Running...")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .gesture(agesture)
        .gesture(bgesture)
//        .gesture(dragGesturemag)
//        .gesture(dragGesturerot)
//        .gesture(dragGesturedrag)
//        .gesture(twoGestures)
        .gesture(threeGestures)
//        .gesture(magnificationAndRotateGesture)
    }
}
//
//struct GestureAnalyze_Previews: PreviewProvider {
//    static var previews: some View {
//        GestureAnalyze()
//    }
//}
