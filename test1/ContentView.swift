//
//  ContentView.swift
//  test1
//
//  Created by Thilo Jeremias on 07.11.21.
//

import SwiftUI
import SceneKit
class myBox: SCNNode {
    override init() {
        var mypos: SCNVector3
        super.init()
        let bx = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.01)
        bx.firstMaterial?.diffuse.contents = CGColor(red: 0.8, green: 0, blue: 0, alpha: 0.6)
        mypos = SCNVector3(0,0,0)
        self.geometry = bx
        self.position = mypos

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
struct ContentView: View {
    @State var thisScene = SCNScene(named: "MyScene.scnassets/Data5.usdz")
    @State var x: CGFloat = 0
    @State var pos: SCNVector3 = SCNVector3(0,0,0)
    var box: SCNNode {
        let bx = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0.01)
        bx.firstMaterial?.diffuse.contents = CGColor(red: 0.8, green: 0, blue: 0, alpha: 0.6)
        let bn = SCNNode(geometry: bx)
        bn.position = pos // SCNVector3Make(x, 0, 0)
        bn.name = "BB"
        return bn
    }
    @State var thisBox = myBox()
    
    var body: some View {
        ZStack{
        SceneView(scene:thisScene,options: [
            .allowsCameraControl,
            .autoenablesDefaultLighting,
            .temporalAntialiasingEnabled
        ])
            VStack {
                HStack {
                    Spacer()
                    Slider(value: $x, in: 0 ... 3){ w in
                        self.pos = SCNVector3(x,0,0)
                    }
                Text("Top")
                    Button("+") {
                        if let nn = self.thisScene?.rootNode {
//                            bn.simdPosition = SIMD3(x,0,0)
//                            nn.addChildNode(box)
                            nn.addChildNode(thisBox)
                            
                        }
                    }
                }
                Spacer()
            }
    }
    }
}

struct ContentView_Previews: PreviewProvider {
 
    static var previews: some View {
        ContentView()
    }
}
