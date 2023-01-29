//
//  ContentView2.swift
//  RealityKit-Sample (macOS)
//
//  Created by Thilo Jeremias on 06.02.22.
//

import SwiftUI
import RealityKit
import UniformTypeIdentifiers

class rObject: ObservableObject {
    @Published var messages: String = "-"
    @Published var mediaProvider: PhotogrammetryFrames?
    @Published var converter: Converter?
    @Published var model: URL?
    @Published var boundingBox: Request.Geometry?
    
}
typealias FeatureSensitivity = PhotogrammetrySession.Configuration.FeatureSensitivity
typealias Ordering = PhotogrammetrySession.Configuration.SampleOrdering

struct ContentView: View {
//    @StateObject private var robj = rObject()
    @EnvironmentObject var robj: rObject
    @State var useBoundaryBox: Bool = false
    func process(titles: [URL]) {
        for url in titles {
            guard let typeID = try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else { return }
            guard let supertypes = UTTypeReference(typeID)?.supertypes else { return }
            print("Proccess \(url) --> \(typeID) --> \(supertypes)")
            if supertypes.contains(.movie) {
                robj.mediaProvider = try? PhotogrammetryFrames(fileURL: url)
                }
            else if supertypes.contains(UTType("public.3d-content")!) {
                robj.model = url
            }
        }
        
    }

    @State private var converterSessionConfig = PhotogrammetrySession.Configuration()
    var body: some View {
        VStack {
            HStack {
                LoadMediaMenu()
                Text( robj.mediaProvider == nil  ? "Please load file or folder to start conversion" : "")
                if robj.converter != nil  {
                    
                    
                    Button(action:{
                        robj.converter?.killSession()
                        robj.messages = " - "
                    },
                        label: {
                        Image(systemName:"xmark.bin.circle.fill")
                        Text("Kill Session")
                    })
                    .disabled(robj.converter?.state == .empty )
                        
                    Button(action:{
                        robj.converter?.runrequest()
                            },
                        label: {
                        Image(systemName:"tray.and.arrow.up.fill")
                        Text("Convert")
                    }).disabled(robj.converter?.state == .digesting )
                }
                if robj.mediaProvider != nil {
                    HStack{
                        if robj.converter != nil {
                            Toggle("Bbox",isOn: $useBoundaryBox)
                                .onChange(of: useBoundaryBox, perform:  { _ in
                                    print("Toggle \(useBoundaryBox)")
                                    robj.converter?.useBoundaryBox = useBoundaryBox
                                    if robj.converter?.boundingBox == nil && useBoundaryBox == true {
                                        robj.converter?.calculateBbox($robj.boundingBox)
                                    }
                                })
                        }
                        Toggle("Masking", isOn:  $converterSessionConfig.isObjectMaskingEnabled)
                        Picker("", selection: $converterSessionConfig.featureSensitivity){
                            Text("Normal").tag(FeatureSensitivity.normal)
                            Text("High").tag(FeatureSensitivity.high)
                        }
                        Picker("", selection:  $converterSessionConfig.sampleOrdering){
                            Text("Sequential").tag(Ordering.sequential)
                            Text("Unordered").tag(Ordering.unordered)
                        }
                    }.onAppear(perform: {
                        robj.converter = nil
                        robj.converter = Converter(input: $robj.mediaProvider, sessionConfig: converterSessionConfig,messages: $robj.messages,model: $robj.model)})
                }
               
                HStack{
                    if let cov = robj.converter  {
                        ConverterRequestMenueView(converter: cov)
                    }
                    if let fl = robj.model   {
                        Button("Hide Model"){ robj.model = nil}
                        SaveModelView(fromURL: fl)
                    }
                    Spacer()
                }

            }
            
            if let cp = robj.converter {
                ConverterRequestContentView(converter: cp)
            }
            ZStack{
                if let md = robj.model  {
                    ConverterModelView(bbox: $robj.boundingBox,modelurl: md)
                } else if let mp = robj.mediaProvider {
                    AMThumbNailView(provider: mp)
                }
                HStack{
                    Spacer()
                    VStack{
                        Spacer()
                        Text(robj.messages)
                    }
                    .frame(width: 300)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .dropDestination(for: URL.self) { receivedTitles, location in
                process(titles: receivedTitles)
                return true

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
            }
          
    }
}


struct ConverterRequestMenueView: View {
    @ObservedObject var converter: Converter
            // A ready request, shall show the model
    // and Bounding box editor
    var body: some View {
        HStack {
            Button("Cancel Request"){ converter.cancelRequest() }
            .disabled(converter.state  != .digesting )
            
            Picker(selection: $converter.detail, label: Text("Quality:")) {
//                Text("Select quality").tag(nil as ViewDetails?)
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



