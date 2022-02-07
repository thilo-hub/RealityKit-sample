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
    
}

struct XContentView: View {
    @StateObject private var robj = rObject()
    
//    var mediaProvider = PhotogrammetryFrames()
//    @StateObject private var converter = ConverterNew()
    @State private var converterSessionConfig = PhotogrammetrySession.Configuration()
    var body: some View {
        VStack {
            HStack {
                LoadMediaMenu(robj: robj)
                Text( robj.mediaProvider == nil  ? "Off" : "Active")
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
                    robj.converter = ConverterNew(input: $robj.mediaProvider, sessionConfig: converterSessionConfig,messages: $robj.messages)})
//                    robj.converter?.messages = $robj.messages
                }
//                .disabled(cmediaProvider != nil)
                HStack{
                    if let cov = robj.converter  {
                        ConverterRequestMenueView2(converter: cov)
                    }
                }

                Spacer()
                Text(robj.messages)
                    .frame(width: 100)
            }
            if let cp = robj.converter {
                ConverterRequestContentView2(converter: cp)
            }
            if robj.converter?.model != nil {
                
                ConverterModelView(converter: robj.converter!)
                
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
//            .disabled(converter.active == false )
            
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
