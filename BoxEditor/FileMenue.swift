//
//  boxresize.swift
//  RealityKit-Sample
//
//  Created by Thilo Jeremias on 23.11.21.
//

import SwiftUI
import UniformTypeIdentifiers
import SceneKit
extension SceneData: ReferenceFileDocument {
    
    typealias Snapshot = SCNScene
    static var readableContentTypes = [UTType.sceneKitScene,UTType.usdz,UTType.data]

    convenience init(configuration: ReadConfiguration) throws {
        self.init()
    }
    
    func snapshot(contentType: UTType) throws -> Snapshot {
        return self.sceneObject
    }
    
    func fileWrapper(snapshot: SCNScene, configuration: WriteConfiguration) throws -> FileWrapper {
        let url = URL(fileURLWithPath: "File_new.scn")
        snapshot.write(to: url, options: [:], delegate: nil, progressHandler: nil)
        let exportedData = try Data(contentsOf: url)
        
        try FileManager.default.removeItem(at: url)
        return FileWrapper(regularFileWithContents: exportedData)
    }
    
}
struct ImportExportCommands: Commands {
     var store: SceneData
    @State private var isShowingExportDialog = false
    @State private var isShowingImportDialog = false

    var body: some Commands {
        CommandGroup(replacing: .importExport) {
            Section {
                Button("Load…") {
                    isShowingImportDialog = true
                }
                    .fileImporter( isPresented: $isShowingImportDialog, allowedContentTypes: SceneData.readableContentTypes) { result in
                    do {
//                    }
                    let url = try result.get()
//                    store.loadedFile = url
                        print(url)
                    let scene = try SCNScene(url: url)
                        let nd = scene.rootNode.clone()
                        let name = url.lastPathComponent
                        nd.name = name
//                        let xb = SCNBox(width: 4, height: 4, length: 4, chamferRadius: 0.1)
//                        let nd = SCNNode(geometry: xb)
                        
                        store.sceneObject.rootNode.addChildNode(nd)
                    }
                        catch {
                            print("Ups")
                        }
                }
                Button("Export…") {
                    isShowingExportDialog = true
                }
                .fileExporter(
                    isPresented: $isShowingExportDialog, document: store,
                    contentType: SceneData.readableContentTypes.first!) { result in
                    }
            }
        }
    }
}

