//
//  TabSelector.swift
//  RealityKit-Sample
//
//  Created by Thilo Jeremias on 23.11.21.
//

import SwiftUI

struct TabSelector: View {
    var body: some View {
        TabView {
            VectorView()
                .tabItem{
                    Image(systemName: "5.square.fill")
                    Text("Vectors")
                }
            BoxEditorContent4()
                .tabItem{
                    Image(systemName: "6.square.fill")
                    Text("Select Faces")
                }
            GestureAnalyze()
                .tabItem {
                    Image(systemName: "4.square.fill")
                    Text("Gestures")
                }
            BoxEditorView()
                .badge(10)
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("First")
                }
            BoxEditorView2()
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("Second")
                }
            BoxEditorView3()
                .tabItem {
                    Image(systemName: "3.square.fill")
                    Text("Third")
                }
        }
        .font(.headline)
    }
}

struct TabSelector_Previews: PreviewProvider {
    static var previews: some View {
        TabSelector()
    }
}
