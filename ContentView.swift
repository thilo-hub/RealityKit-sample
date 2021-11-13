//
//  ContentView.swift
//  Shared
//
//  Created by Thilo Jeremias on 01.11.21.
//

import SwiftUI
import AppKit
import os
import RealityKit

typealias MyDetail = ViewDetails?

enum ViewDetails: String, CaseIterable {
    case preview
    case reduced
    case medium
    case full
    var det: Request.Detail {
        switch self {
        case .preview: return PhotogrammetrySession.Request.Detail.preview
        case .reduced: return PhotogrammetrySession.Request.Detail.reduced
        case .medium: return PhotogrammetrySession.Request.Detail.medium
        case .full: return PhotogrammetrySession.Request.Detail.full
        }
    }
        
}

struct ContentView: View {
    @State var filename: URL? // = "Filename"
    @State var input: URL?
    @StateObject private var converter = Converter()
//    @StateObject private var images = AllImages()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if self.filename != nil {
                    Text(input?.lastPathComponent ?? "--")
                    if  converter.state == .loaded {
                        Picker(selection: $converter.detail, label: Text("Detail")) {
                        ForEach(ViewDetails.allCases, id: \.self) { element in
                            Text(element.rawValue.capitalized).tag(element as ViewDetails?)                                             }
                                          }
                        
                    .onSubmit({print ("Submit")})
                    }
                    if let model = converter.model {
                        Button("Save model") {
                            let panel = NSSavePanel()
                            panel.allowedContentTypes = [.usdz]
                            if panel.runModal() == .OK {
                                if let url = panel.url {
                                    try? FileManager.default.moveItem(at: model, to: url)
                                }
                            }

                        }
                    }
                }
                Button("Open file")
                {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                     // panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    if panel.runModal() == .OK {
                        if let url = panel.url {
                            self.filename = url
                            switch url {
                            case let(dir) where panel.directoryURL == url:
                                converter.input = dir
                            case let(model) where url.pathExtension == "usdz":
                                converter.model = model
                                print("Lost 3d viewer")
                            default:
                                converter.input = url
                                
                            }

                        }

                    }
              }
            }
            ConverterView(converter: converter)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    
 
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
