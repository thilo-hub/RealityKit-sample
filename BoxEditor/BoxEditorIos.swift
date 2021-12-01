//
//  BoxEditorApp.swift
//  Shared
//
//  Created by Thilo Jeremias on 21.11.21.
//

import SwiftUI
import SceneKit

@main
struct BoxEditorApp: App {
    @StateObject private var scene = SceneData()
    var body: some Scene {
        WindowGroup {
//            testWhyNot()
            TabSelector()
                .environmentObject(scene)
        }
    }

}

