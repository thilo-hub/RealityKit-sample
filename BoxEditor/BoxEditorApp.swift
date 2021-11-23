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
//            BoxEditorView()
//                .environmentObject(scene)
//            BoxEditorView2()
//                .environmentObject(scene)
//            BoxEditorView3()
            TabSelector()
                .environmentObject(scene)
        }
        .commands {
            SidebarCommands()
//            PlantCommands()
            ImportExportCommands(store: scene)
            ImportFromDevicesCommands()
        }
        Settings {
//            SettingsView()
//                .environmentObject(store)
        }
}
}

