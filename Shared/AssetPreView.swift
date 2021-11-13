//
//  ContentView.swift
//  testMovie
//
//  Created by Thilo Jeremias on 10.11.21.
//

import SwiftUI
import RealityKit

func convertCIImageToCGImage(_ inputImage: CIImage) -> CGImage? {
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
        return cgImage
    }
    return nil
}


extension  Converter {
    func setAll(flag: Bool){
        for i in thumbnails.indices {
            thumbnails[i].isenabled = flag
        }
    }
}
struct ThumbNailView: View {
    
    @ObservedObject var converter:  Converter
    @State var toggle: Bool = true

    var body: some View {
        let columns: [GridItem] =
                 Array(repeating: .init(.adaptive(minimum: 120)), count: 8)
        VStack{
            HStack{
                Stepper(value: $converter.skip,
                        in: 0...10,
                        step: 1) {
                    Text("Skip: \(converter.skip)  ")
                }

                let cnt =  converter.thumbnails
                Text("Frames: \(cnt.count)")
                Button("Deselect all"){
                    self.converter.setAll(flag: false)
                }
                Button("Select all"){
                    self.converter.setAll(flag: true)
                }

            }
            ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 10) {
                
                
                ForEach($converter.thumbnails){ $im  in
                VStack {
                    Image(nsImage: im.thumbnail )
                        .onTapGesture { im.isenabled = !im.isenabled}
                    HStack{
                        Text("\(im.id)")
                        Spacer()
                        Toggle("", isOn: $im.isenabled)
                    }
                   
                }
                    .padding()
                }
            
            }
         }
        
       .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        
    }
}
