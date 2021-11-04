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


//struct ContentView: View {
//    var body: some View {
//        Text("Hello, world!")
////        Scenekit()
//            .padding()
//    }
//}
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
    @State var filename = "Filename"
//    @State var showFileChooser = false
    @StateObject var converter = Converter()
    
    /// Called when the the session sends a request completed message.
    func handleRequestComplete(request: PhotogrammetrySession.Request,
                                              result: PhotogrammetrySession.Result) {
        logger.log("Request complete: \(String(describing: request)) with result...")
        switch result {
            case .modelFile(let url):
                logger.log("\tmodelFile available at url=\(url)")
            default:
                logger.warning("\tUnexpected result: \(String(describing: result))")
        }
    }
    

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(filename)
                Picker(selection: $converter.detail, label: Text("Detail")) {
                    ForEach(ViewDetails.allCases, id: \.self) { element in
                                              Text(element.rawValue.capitalized)
                                          }
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
                 Button("Convert file")
                {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                     // panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    if panel.runModal() == .OK {
                        if let url = panel.url {
                            self.filename = url.lastPathComponent
                            switch url {
                            case let(dir) where panel.directoryURL == url:
                                converter.input = dir
                            case let(model) where url.pathExtension == "usdz":
                                converter.model = model
                            default:
                                converter.input = url
                            }
                          
                        }
                        
                    }
              }
            }
            ConverterView(converter: converter)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    
 
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
