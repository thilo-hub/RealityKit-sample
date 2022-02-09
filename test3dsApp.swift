//
//  test3dsApp.swift
//  Shared
//
//  Created by Thilo Jeremias on 01.11.21.
//

import SwiftUI

@main
struct test3dsApp: App {
    @StateObject private var robj = rObject()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(robj)
        }
    }
}
