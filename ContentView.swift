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

struct ContentView__: View {
    @State var filename: URL? // = "Filename"
    @State var input: URL?
    @StateObject private var converter = Converter()
    typealias FeatureSensitivity = PhotogrammetrySession.Configuration.FeatureSensitivity
    typealias Ordering = PhotogrammetrySession.Configuration.SampleOrdering
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if converter.model != nil {
                    Button("Clear"){ converter.model = nil}
                }
                HStack {
                     if let s = converter.session {
                        if s.isProcessing {
                            Button("Cancel Request"){converter.cancelRequest()}
                        } else {
                            Button("Kill Session"){converter.killSession()}
                        }
                        
                    }
                }
                .disabled(converter.state == ConverterState.empty )
                
                HStack{
                    Toggle(isOn:  $converter.sessionConfig.isObjectMaskingEnabled) {
                        Text("Masking")
                    }
                    Picker("", selection: $converter.sessionConfig.featureSensitivity){
                        Text("Normal").tag(FeatureSensitivity.normal)
                        Text("High").tag(FeatureSensitivity.high)
                    }
                    Picker("", selection:  $converter.sessionConfig.sampleOrdering){
                        Text("Sequential").tag(Ordering.sequential)
                        Text("Unordered").tag(Ordering.unordered)
                    }
                }
                .disabled(converter.state != ConverterState.empty )

                if self.filename != nil {
                    Text(input?.lastPathComponent ?? "--")
                    if  converter.state != .empty {
                        Picker(selection: $converter.detail, label: Text("Request")) {
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
//            ConverterView(converter: converter)

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
