//
//  ContentView.swift
//  Shared
//
//  Created by Thilo Jeremias on 11.11.21.
//

import SwiftUI

struct ContentView: View {
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
        ZStack {
            Text("Hello")
                .padding(10)
                .background(Color.red)
                .opacity(0.8)
            Text("World")
                .padding(20)
                .background(Color.red)
                .offset(x: 0, y: 40)
        }
//            HStack { Spacer() }
//            GeometryReader { geometry in
//                        VStack {
//                            Text("\(geometry.size.width) x \(geometry.size.height)")
//                        }.frame(width: geometry.size.width, height: geometry.size.height)
//                    }
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(0...100, id: \.self) { _ in
                    Color.orange.frame(width: 100, height: 100)
                }
            }
        }
        .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(minWidth: 900, idealWidth: 1200, maxWidth: nil, minHeight: 400, idealHeight: 1000, maxHeight: nil, alignment: .center)
    }
}
