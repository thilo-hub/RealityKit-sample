//
//  File.swift
//  test3ds
//
//  Created by Thilo Jeremias on 03.11.21.
//
import SwiftUI
import SceneKit
import RealityKit
struct LoadFileView: View {
    @StateObject var converter: Converter
    
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
}

struct ConverterThumbnailView: View {
    @ObservedObject var converter: Converter
    // A session shall let you modify request parameter and let you start a request
    var body: some View {
        
        if converter.thumbnails.count > 0{
                ThumbNailView(converter: converter, toggle: true)
        }
     }
}
struct ConverterRequestContentView: View {
    @ObservedObject var converter: Converter

    // A ready request, shall show the model
    // and Bounding box editor
        var body: some View {
            if let f = converter.progressValue {
                    ProgressView(value: f)
//            } else if let fl = converter.model {
//                if let s = try? SCNScene(url: fl) {
//                    BoundBoxEditorView(myscene: s,boundingBox: $converter.bBox)
//                }
            }
          
    }
}


struct ConverterSessionMenueView: View {
    @ObservedObject var converter: Converter
    var body: some View {
        Button("Kill Session"){ converter.killSession() }
        .disabled(converter.session == nil)
        if let furl = converter.input  {
            Button("Reload \(furl)") { converter.input = furl}
        }
    }
}



typealias FeatureSensitivity = PhotogrammetrySession.Configuration.FeatureSensitivity
typealias Ordering = PhotogrammetrySession.Configuration.SampleOrdering

struct ConverterMenueView: View {
    @StateObject var converter: Converter
    var body: some View {
        HStack {
            LoadFileView(converter: converter)
            ConverterSessionMenueView(converter:converter)
            ConverterRequestMenueView(converter: converter)
            Toggle(isOn: $converter.disableFolders ) {
                Text("-Dirs-")
            }
            HStack{
//                Toggle(isOn: $converter.)
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
            .disabled(converter.session != nil)
        }
    }
}

struct ConverterContentView: View {
    @StateObject var converter: Converter

    var body: some View {
        VStack{
            ConverterRequestContentView(converter:converter)
            if converter.model == nil {
                ConverterThumbnailView(converter:converter)
            }
            if converter.model != nil {
                ConverterModelView(converter:converter)
            }
        }
    }
}

struct ContentView: View {
    @State var filename: URL? // = "Filename"
    @State var input: URL?
    @StateObject private var converter = Converter()

    
    
    var body: some View {
        VStack {
            ConverterMenueView(converter: converter)
            Text( converter.stateInfo )
            ConverterContentView(converter: converter)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ConverterRequestMenueView: View {
    @ObservedObject var converter: Converter
            // A ready request, shall show the model
    // and Bounding box editor
    var body: some View {
        HStack {
            Button("Cancel Request"){ converter.cancelRequest() }
            .disabled(converter.active == false )
            
            Picker(selection: $converter.detail, label: Text("Request:")) {
                Text("Select quality").tag(nil as ViewDetails?)
                ForEach(ViewDetails.allCases, id: \.self) { element in
                    Text(element.rawValue.capitalized).tag(element as ViewDetails?)
                    
                }
            }
        }
        .disabled(converter.state == .digesting)
        if let fl = converter.model {
            Button("Hide Model"){ converter.model = nil}
            SaveModelView(fromURL: fl)
            Toggle(isOn: $converter.boundingBoxEnabled) {
                Text("Bbox")
            }
//            Button("Hide BBox"){
//                converter.
//            }
        }

    
    }
    
}


struct __ConverterSessionMenueView: View {
    @ObservedObject var converter: Converter
    var body: some View {
        Button("Kill Session"){ converter.killSession() }
        .disabled(converter.session == nil)
        if let furl = converter.input  {
            Button("Reload \(furl)") { converter.input = furl}
        }
    }
}

