//
//  RequestView.swift
//  RealityKit-Sample (macOS)
//
//  Created by Thilo Jeremias on 06.02.22.
//

import SwiftUI
import RealityKit


struct ConverterRequestMenueViewNew: View {
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
