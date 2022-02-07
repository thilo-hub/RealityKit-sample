//
//  AMThumbView.swift
//  RealityKit-Sample (macOS)
//
//  Created by Thilo Jeremias on 07.02.22.
//

import SwiftUI
import RealityKit


extension  PhotogrammetryFrames {
    func setAll(flag: Bool){
        for i in thumbnails.indices {
            thumbnails[i].isenabled = flag
        }
    }
}



struct AMThumbNailView: View {
    
    @ObservedObject var provider:  PhotogrammetryFrames
    @State var toggle: Bool = true

    var body: some View {
        let columns: [GridItem] =
                 Array(repeating: .init(.adaptive(minimum: 120)), count: 8)
        VStack{
            HStack{
                Stepper(value: $provider.skip,
                        in: 0...10,
                        step: 1) {
                    Text("Skip: \(provider.skip)  ")
                }

                let cnt =  provider.thumbnails
                Text("Frames: \(cnt.count)")
                Button("Deselect all"){
                    self.provider.setAll(flag: false)
                }
                Button("Select all"){
                    self.provider.setAll(flag: true)
                }

            }
            ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 10) {
                
                
                ForEach($provider.thumbnails){ $im  in
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
