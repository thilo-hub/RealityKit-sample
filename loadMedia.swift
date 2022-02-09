//
//  loadMedia.swift
//  RealityKit-Sample (macOS)
//
//  Created by Thilo Jeremias on 06.02.22.
//

import SwiftUI



struct LoadMediaMenu: View {
//    @ObservedObject var robj: rObject
    @EnvironmentObject var robj: rObject
//    @Binding var robj: rObject
    
    var body: some View {
        Button("Load File"){
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
             // panel.canChooseFiles = false
            panel.canChooseDirectories = true
            if panel.runModal() == .OK {
                if let url = panel.url {
                    switch url {
                    case let(dir) where panel.directoryURL == url:
                        print("Dir")
//                        converter.input = dir
                        robj.mediaProvider = try? PhotogrammetryFrames(fileURL: dir, disableFolders: true)
                    case let(model) where url.pathExtension == "usdz":
//                        converter.model = model
                        robj.model = model
                        print("Lost 3d viewer \(model)")
                    default:
                        print("Other")
//                        converter.input = url
                        robj.mediaProvider = try? PhotogrammetryFrames(fileURL: url, disableFolders: false)
                        
                    }

                }

            }
        }
    }
}
