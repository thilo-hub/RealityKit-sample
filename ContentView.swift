//
//  ContentView2.swift
//  RealityKit-Sample (macOS)
//
//  Created by Thilo Jeremias on 06.02.22.
//

import SwiftUI
import RealityKit
import UniformTypeIdentifiers


typealias FeatureSensitivity = PhotogrammetrySession.Configuration.FeatureSensitivity
typealias Ordering = PhotogrammetrySession.Configuration.SampleOrdering

struct ContentView: View {
    var url:URL?

    @EnvironmentObject var robj: rObject
    @Environment(\.openURL) private var openURL
    @Environment(\.undoManager) var undoManager


    func process(titles: [URL]) {
        for url in titles {
            guard let typeID = try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else { return }
            guard let supertypes = UTTypeReference(typeID)?.supertypes else { return }
            print("Proccess \(url) --> \(typeID) --> \(supertypes)")
            if supertypes.contains(.movie) || supertypes.contains(.directory) {
                Task {
                    robj.mediaProvider = try? await PhotogrammetryFrames(fileURL: url)
                    robj.inMedia = url
                }
            }
            else if supertypes.contains(.threeDContent)  {
                robj.model = url
            }
        }
    }

    var body: some View {
        VStack {
            HStack {
                if (robj.model != nil) {
                    ModelView()
                } else if let inMedia = robj.inMedia {
                    PicturesView( url: inMedia, closeView: { robj.inMedia = nil })
                } else {
                    FileLoaderView(loaded: { url in
                            process(titles: [url])
                        
                    })
                }
            }
        }
        .onAppear() {
            if let inMedia = url {
                    process(titles: [inMedia])
                }
        }
        .environmentObject(robj)
        .onOpenURL(perform: {
            url in process(titles:[url]) }
        )

        .dropDestination(for: URL.self) {
            receivedTitles, location in
            process(titles: receivedTitles)
            return true
        }

    }
}




