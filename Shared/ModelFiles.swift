//
//  ModelFiles.swift
//  RealityKit-Sample (macOS)
//
//  Created by Thilo Jeremias on 07.02.22.
//

import SwiftUI


struct SaveModelView: View {
    var fromURL: URL
    var body: some View {
        Button("Save model") {
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.usdz]
            if panel.runModal() == .OK {
                if let url = panel.url {
                    try? FileManager.default.moveItem(at: fromURL, to: url)
                }
            }

        }

    }
}
