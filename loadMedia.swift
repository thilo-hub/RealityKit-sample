//
//  loadMedia.swift
//  RealityKit-Sample (macOS)
//
//  Created by Thilo Jeremias on 06.02.22.
//

import SwiftUI



struct LoadMediaMenu: View {
    @EnvironmentObject var robj: rObject
    
    fileprivate func loadFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        // panel.canChooseFiles = false
        panel.canChooseDirectories = true
        if panel.runModal() == .OK {
            if let url = panel.url {
                if url != robj.mediaProvider?.url {
                    // URL changed, invalidate session
                    robj.converter?.killSession()
                }
                switch url {
                case let(dir) where panel.directoryURL == url:
                    robj.mediaProvider = try? PhotogrammetryFrames(fileURL: dir)
                case let(model) where url.pathExtension == "usdz":
                    robj.model = model
                default:
                    robj.mediaProvider = try? PhotogrammetryFrames(fileURL: url)
                }
                
            }
            
        }
    }
    
    var body: some View {
        Button(action:{
            loadFile()
        },
            label: {
            Image(systemName:"tray.and.arrow.down.fill")
            Text("Load File")
        })
    }
}
