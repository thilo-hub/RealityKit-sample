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
        for i in images.indices {
            images[i].isenabled = flag
        }
    }
}
struct MovieViewer: View {
    
    @ObservedObject var Movie:  Converter
    @State var toggle: Bool = true

    var body: some View {
        let columns: [GridItem] =
                 Array(repeating: .init(.adaptive(minimum: 120)), count: 8)
        VStack{
            HStack{
                let cnt =  Movie.images
                Text("Frames: \(cnt.count)")
                Button("Deselect all"){
                    self.Movie.setAll(flag: false)
                }
                Button("Select all"){
                    self.Movie.setAll(flag: true)
                }

            }
            ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 10) {
                
                
                ForEach($Movie.images){ $im  in
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
