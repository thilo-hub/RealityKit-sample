//
//  test3dsApp.swift
//  Shared
//
//  Created by Thilo Jeremias on 01.11.21.
//

import SwiftUI

@main
struct RealityMaker: App {
    var body: some Scene {
        DocumentGroup(newDocument: { rObject() } ) { pp in
            ContentView( url: pp.fileURL)
                .environmentObject(pp.document)
        }
    }
}
