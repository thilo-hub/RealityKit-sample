//
//  ContentView.swift
//  Shared
//
//  Created by Thilo Jeremias on 01.11.21.
//

import SwiftUI
import SceneKit
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

struct ConverterView: View {
//     var model: URL?
//    var inputFolder: URL?
//     var progress: Double?
//     var details: ViewDetails
    @ObservedObject var converter: Conv2
    
    
    var scene: SCNScene? {
        //SCNScene(named: "MyScene.scnassets/Data5.usdz")
        
        if let fileURL = converter.model {
            return try? SCNScene(url: fileURL)
        }
        return nil
        
            
    }
    var cameraNode: SCNNode? {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        return cameraNode
    }
     


    var body: some View {
        if let s = scene {
            Text("Here")
            SceneView(
                scene: s,
                pointOfView: cameraNode,
                options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                ]
            )
        } else if let f = converter.progressValue {
            VStack {
             ProgressView(value: f)
                Spacer()
            }
        } else
        {
            Text("Please select a directory to convert")
        }
//        if let m = model {
//            Text("File there")
//                ProgressView(value: progress)
//
//       } else {
//            Text("Nothing")
//           SceneView(
//               scene: scene,
//               pointOfView: cameraNode,
//               options: [
//                   .allowsCameraControl,
//                   .autoenablesDefaultLighting,
//                   .temporalAntialiasingEnabled
//               ]
//           )
//
//        }
        
    }
}

struct ContentView: View {
    @State var filename = "Filename"
//    @State var model: URL?
    @State var showFileChooser = false
    @StateObject var converter = Conv2()
//    @State private var details : ViewDetails = .preview
    
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
    
//    /// Called when the sessions sends a progress update message.
//    func handleRequestProgress(request: PhotogrammetrySession.Request,
//                                              fractionComplete: Double) {
//        logger.log("Progress(request = \(String(describing: request)) = \(fractionComplete)")
//    }


    var body: some View {
        VStack {
            HStack {
//                ProgressView(value: converter?.progressValue )
                 Text(filename)
                Picker(selection: $converter.detail, label: Text("Detail")) {
                                            ForEach(ViewDetails.allCases, id: \.self) { element in
                                                Text(element.rawValue.capitalized)
                                            }
                                        }
                       
                 
                Button("select File")
                {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = false
                      panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    if panel.runModal() == .OK {
                        self.filename = panel.url?.lastPathComponent ?? "<none>"
//                        let outputFilename = "testing.usdz"
//                        let outputUrl = URL(fileURLWithPath: outputFilename)

//                        self.model = outputUrl
                       // self.fileURL = panel.url!
                        converter.fileURL = panel.url! //  = Conv2(input: panel.url!,detail: details)
    //                    converter.run(inputFolderUrl: panel.url!)
                    }
              }
            }
            ConverterView(converter: converter) // model: $model,details: $details)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    
 
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
