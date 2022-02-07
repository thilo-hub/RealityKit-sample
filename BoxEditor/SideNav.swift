//
//  SideNav.swift
//  RealityKit-Sample
//
//  Created by Thilo Jeremias on 04.12.21.
//

//
//  TabSelector.swift
//  RealityKit-Sample
//
//  Created by Thilo Jeremias on 23.11.21.
//

import SwiftUI

struct NavItems {
    var vectors2:Bool = false
    var vectors:Bool = false
    var faces:Bool = false
    var gestures:Bool = false
    var first:Bool = false
    var second:Bool = false
    var third:Bool = false
    var hierarchie:Bool = false
}
struct SideNav: View {
    @State var select:NavItems = NavItems(vectors2: true)

    var body: some View {

        NavigationView {
            List {
            NavigationLink("Vectors2",  destination: VectorView2(), isActive: $select.vectors2 )
            NavigationLink("Vectors",  destination: VectorView(), isActive: $select.vectors )
            NavigationLink("Select Faces",destination: BoxEditorContent4(), isActive: $select.faces )
            NavigationLink("Gestures",destination: GestureAnalyze(), isActive: $select.gestures )
            NavigationLink("First",destination: BoxEditorView(), isActive: $select.first )
            NavigationLink("Second",destination: BoxEditorView2(), isActive: $select.second )
            NavigationLink("Third",destination: BoxEditorView3(), isActive: $select.third )
            NavigationLink("Hierachie",destination: HierarchieView(), isActive: $select.hierarchie )
            }
        }
        .font(.headline)
    }
}
//
//struct SideNav_Previews: PreviewProvider {
//    static var previews: some View {
//        SideNav()
//    }
//}
