//
//  PicturesView.swift
//  RealityConverter
//
//  Created by Thilo Jeremias on 29.01.23.
//

import SwiftUI
import RealityKit

struct PicturesView: View {
    var url: URL
    @EnvironmentObject var robj: rObject

    let closeView: () -> Void
    @State var useBoundaryBox: Bool = false
    @State private var converterSessionConfig = PhotogrammetrySession.Configuration()

    var body: some View {
        VStack {
            HStack {
                Button(action:{
                                    robj.converter?.killSession()
                                    robj.messages = " - "
                    closeView()
                },
                       label: {
                    Image(systemName:"xmark.bin.circle.fill")
                    Text("Close Session")
                })
                
                Toggle("Bbox",isOn: $useBoundaryBox)
                    .onChange(of: useBoundaryBox, perform:  { _ in
                        print("Toggle \(useBoundaryBox)")
                        //                            robj.converter?.useBoundaryBox = useBoundaryBox
                        //                            if robj.converter?.boundingBox == nil && useBoundaryBox == true {
                        //                                robj.converter?.calculateBbox($robj.boundingBox)
                        //                            }
                    })
                
                Toggle("Masking", isOn:  $converterSessionConfig.isObjectMaskingEnabled)
                
                Picker("", selection: $converterSessionConfig.featureSensitivity){
                    Text("Normal").tag(FeatureSensitivity.normal)
                    Text("High").tag(FeatureSensitivity.high)
                }
                
                Picker("", selection:  $converterSessionConfig.sampleOrdering){
                    Text("Sequential").tag(Ordering.sequential)
                    Text("Unordered").tag(Ordering.unordered)
                }
                if let cov = robj.converter  {
                    ConverterRequestMenueView(converter: cov)
                }
                Button(action:{ robj.converter?.runrequest()},
                       label: { Image(systemName:"tray.and.arrow.up.fill")
                                Text("Convert")
                    })
                    .disabled(robj.converter?.state != .ready)
                
                
            }
            if let cp = robj.converter {
                ConverterProgressView(converter: cp)
            }

            if let mp = robj.mediaProvider {
                AMThumbNailView(provider: mp)
            }
        }
        .onAppear(perform: {
            robj.converter = Converter(input: $robj.mediaProvider, sessionConfig: converterSessionConfig,messages: $robj.messages,model: $robj.model)

        })
            
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
                ForEach(ViewDetails.allCases, id: \.self) { element in
                    Text(element.rawValue.capitalized).tag(element as ViewDetails?)
                    
                }
            }
        }
        .disabled(converter.state == .digesting)
    }
    
}


//struct PicturesView_Previews: PreviewProvider {
//    static var previews: some View {
//        PicturesView()
//    }
//}
