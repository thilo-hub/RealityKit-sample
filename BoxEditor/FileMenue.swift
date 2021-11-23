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
    static var readableContentTypes = [UTType.sceneKitScene]

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
    var store:SceneData
    @State private var isShowingExportDialog = false

    var body: some Commands {
        CommandGroup(replacing: .importExport) {
            Section {
                Button("Load…") { }
                //                .fileImporter
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

