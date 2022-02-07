//
//  Tester.swift
//  RealityKit-Sample
//
//  Created by Thilo Jeremias on 04.12.21.
//

import SwiftUI
import SceneKit

extension SCNNode: Identifiable {
    var children: [SCNNode]? {
        let ch:[SCNNode]? = self.childNodes
        return ch
    }
    var who: String {
        print(self.boundingBox)
        var descr: String = ""
        descr += (self.camera != nil) ? "🎥 " : ""
        descr += self.name ?? self.description
        let maxx = self.boundingBox.max.x
        let maxy = self.boundingBox.max.y
        let maxz = self.boundingBox.max.z
        let minx = self.boundingBox.min.x
        let miny = self.boundingBox.min.y
        let minz = self.boundingBox.min.z
        descr += " BBX(\(minx)/\(miny)/\(minz) X \(maxx)/\(maxy)/\(maxz))"
        descr += " Pos:" + self.simdPosition.description
        return descr
    }
}
struct HierarchieView: View {
    @EnvironmentObject var sceneViewStore: SceneData
    var body: some View {
        List(sceneViewStore.sceneObject.rootNode.childNodes, children: \.children) { item in
            HStack{
                Text(item.who)
                Button(" 🗑"){
                    print ("Delete \(item.description)")
                    item.removeFromParentNode()
                }.disabled( item.camera != nil)
                //    { item in item.camera != nil })
            }
        }
    }
    
}

//struct Tester_Previews: PreviewProvider {
//    static var previews: some View {
//        TesterView()
//    }
//}
