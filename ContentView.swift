//
//  ContentView2.swift
//  RealityKit-Sample (macOS)
//
//  Created by Thilo Jeremias on 06.02.22.
//

import SwiftUI
import RealityKit

class rObject: ObservableObject {
    @Published var messages: String = "-"
    @Published var mediaProvider: PhotogrammetryFrames?
    @Published var converter: ConverterNew?
    @Published var model: URL?
    
}
typealias FeatureSensitivity = PhotogrammetrySession.Configuration.FeatureSensitivity
typealias Ordering = PhotogrammetrySession.Configuration.SampleOrdering

struct XContentView: View {
    @StateObject private var robj = rObject()
    
//    var mediaProvider = PhotogrammetryFrames()
//    @StateObject private var converter = ConverterNew()
    @State private var converterSessionConfig = PhotogrammetrySession.Configuration()
    var body: some View {
        VStack {
            HStack {
                LoadMediaMenu(robj: robj)
                Text( robj.mediaProvider == nil  ? "Please load file or folder to start conversion" : "")
                if robj.mediaProvider != nil {
                    HStack{
        //                Toggle(isOn: $converter.)
                        Toggle(isOn:  $converterSessionConfig.isObjectMaskingEnabled) {
                            Text("Masking")
                        }
                        Picker("", selection: $converterSessionConfig.featureSensitivity){
                            Text("Normal").tag(FeatureSensitivity.normal)
                            Text("High").tag(FeatureSensitivity.high)
                        }
                        Picker("", selection:  $converterSessionConfig.sampleOrdering){
                            Text("Sequential").tag(Ordering.sequential)
                            Text("Unordered").tag(Ordering.unordered)
                        }
                    }.onAppear(perform: {
                        robj.converter = ConverterNew(input: $robj.mediaProvider, sessionConfig: converterSessionConfig,messages: $robj.messages,model: $robj.model)})
//                    robj.converter?.messages = $robj.messages
                }
//                .disabled(cmediaProvider != nil)
                HStack{
                    if let cov = robj.converter  {
                        ConverterRequestMenueView2(converter: cov)
                    }
                    if let fl = robj.model   {
                        Button("Hide Model"){ robj.model = nil}
                        SaveModelView(fromURL: fl)
                    }
                }

                Spacer()
                Text(robj.messages)
                    .frame(width: 100)
            }
            if let cp = robj.converter {
                ConverterRequestContentView2(converter: cp)
            }
            if robj.model != nil {
                ConverterModelView(converter: robj.converter!,model: robj.model!)
                
            } else
            if let mp = robj.mediaProvider {
                AMThumbNailView(provider: mp)
                
            } //.disabled(mediaProvider == nil)
            

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ConverterRequestContentView2: View {
    @ObservedObject var converter: ConverterNew

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


struct ConverterRequestMenueView2: View {
    @ObservedObject var converter: ConverterNew
            // A ready request, shall show the model
    // and Bounding box editor
    var body: some View {
        HStack {
            Button("Cancel Request"){ converter.cancelRequest() }
            .disabled(converter.state  != .digesting )
            
            Picker(selection: $converter.detail, label: Text("Request:")) {
                Text("Select quality").tag(nil as ViewDetails?)
                ForEach(ViewDetails.allCases, id: \.self) { element in
                    Text(element.rawValue.capitalized).tag(element as ViewDetails?)
                    
                }
            }
        }
        .disabled(converter.state == .digesting)
//        if let fl = converter.model {
            
            
//            Toggle(isOn: $converter.boundingBoxEnabled) {
//                Text("Bbox")
//            }
//            Button("Hide BBox"){
//                converter.
//            }
//        }

    
    }
    
}
