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
            thumbnails[i].isEnabled = flag
        }
    }
    func disable(_ id: Int){
        for i in thumbnails.indices {
            if thumbnails[i].id == id {
                thumbnails[i].isEnabled = false
            }
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
                let cnt =  provider.thumbnails
                Text(provider.url?.lastPathComponent ?? "File: ?")
                Stepper(value: $provider.first,
                        in: 0...provider.last,
                        step: 1) {
                    Text("First: \(provider.first)  ")
                }
                Stepper(value: $provider.skip,
                        in: 0...10,
                        step: 1) {
                    Text("Skip: \(provider.skip)  ")
                }
                Stepper(value: $provider.last,
                        in: provider.first...cnt.count,
                        step: 1) {
                    Text("Last: \(provider.last)  ")
                }
                        .onSubmit {
                            print("HiHo")
                        }

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
                    if !im.isHidden {
                        VStack {
                            ZStack{
                                Image(nsImage: im.thumbnail )
                                    .onTapGesture { im.isEnabled = !im.isEnabled}
                                if let ms = im.mask {
                                    Rectangle().offset(ms.origin).size(ms.size).stroke(Color.red)
                                }
                                
                            }
                            HStack{
                                Text("\(im.id)")
                                Spacer()
                                Toggle("", isOn: $im.isEnabled)
                            }
                            
                        }
                        .padding()
                    }
                
                }
            
            }
         }
        
       .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        
    }
}
