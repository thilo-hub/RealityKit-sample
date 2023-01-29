//
//  DocumentConfig.swift
//  RealityConverter
//
//  Created by Thilo Jeremias on 30.01.23.
//
//
import SwiftUI
import UniformTypeIdentifiers

class convProject: ReferenceFileDocument {
    
    
    var text: String
    static var readableContentTypes: [UTType] { [.text] }
    typealias Snapshot = String

    init(text:String = "Hello World") {
        self.text = text
        
    }
     /// - Tag: Snapshot
    func snapshot(contentType: UTType) throws -> Snapshot {
        text // Make a copy.
    }

    
    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let pers = try? JSONDecoder().decode(String.self, from: data)
        text = pers ?? "--"

     }
    func fileWrapper(snapshot: Snapshot, configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(snapshot)
        return FileWrapper(regularFileWithContents: data)
    }
}



final class rObject: ReferenceFileDocument,ObservableObject,Identifiable {

    typealias Snapshot = persData
    
    @Published var inMedia:URL?
    @Published var messages: String = "-"
    @Published var mediaProvider: PhotogrammetryFrames?
    @Published var converter: Converter?
    @Published var model: URL?
    @Published var boundingBox: Request.Geometry?
    struct persData: Codable {
        let inMedia:URL?
        let model:URL?
    }
    // Define the document type this app is able to load.
    /// - Tag: ContentType
    static var readableContentTypes: [UTType] { [.movie, .directory, .threeDContent] }
        
        /// - Tag: Snapshot
        func snapshot(contentType: UTType) throws -> Snapshot {
            persData(inMedia:inMedia,model:model) // Make a copy.
        }
        
    init() {
        print("Init ")
        }

        // Load a file's contents into the document.
        /// - Tag: DocumentInit
        init(configuration: ReadConfiguration) throws {
            guard let data = configuration.file.regularFileContents
            else {
                throw CocoaError(.fileReadCorruptFile)
            }
            //self.model =
            let pers = try? JSONDecoder().decode(persData.self, from: data)
            self.model = pers?.model
            self.inMedia = pers?.inMedia
            if let inMedia {
                Task {
                    self.mediaProvider = try? await PhotogrammetryFrames(fileURL: inMedia)
                }
            }
        }
        
//        /// Saves the document's data to a file.
//        /// - Tag: FileWrapper
        func fileWrapper(snapshot: Snapshot, configuration: WriteConfiguration) throws -> FileWrapper {
            let data = try JSONEncoder().encode(snapshot)
            return FileWrapper(regularFileWithContents: data)
        }
    }
