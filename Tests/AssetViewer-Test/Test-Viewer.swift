//
//  testMovieApp.swift
//  testMovie
//
//  Created by Thilo Jeremias on 10.11.21.
//

import SwiftUI

@main
struct testMovieApp: App {
    let url = Bundle.main.url(forResource: "IMG_1537", withExtension: "MOV")!
    @ObservedObject var images: AllImages = AllImages( )
    var body: some Scene {
        WindowGroup {
            MovieViewer(Movie: images, toggle: false)
                .onAppear(perform: {images.fileURL=url})
        }
    }
}
