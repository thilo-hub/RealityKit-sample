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

func PSession() -> PhotogrammetryFrames? {
    let url = URL(fileURLWithPath:"/Users/thilo/Downloads/3dcap/IMG_1668.MOV")

    let rv = try? PhotogrammetryFrames(fileURL: url)
    return rv
}
//func mystr() -> [Int:Image] {
//    var images: [Int:Image] = [:]
//    let url = URL(fileURLWithPath:"/Users/thilo/Downloads/3dcap/IMG_1668.MOV")
//
//    var rv = try? PhotogrammetryFrames(fileURL: url)
//    let size: CGSize = CGSize(width: 60, height: 90)
//
//    let f = rv!
//    print(f)
//       // let scale = UIScreen.main.scale
////    let k=rv?.first
//
//    for i in 1...20 {
//        let r = rv?.next()!
//        if let im = r?.image {
//            let px:CVBuffer = im
//            let cg1 = CIImage(cvPixelBuffer: px)
//
//
//            if let cgim = convertCIImageToCGImage(cg1) {
//                let im1 = NSImage(cgImage: cgim, size: size)
//                images[i] = Image(nsImage:im1)
//            }
//        }
//    }
//  return images
//}
struct ImageFrame: Identifiable {
    var id:Int
    var image: NSImage
    var isenabled: Bool = true
}
extension PhotogrammetryFrames {
    mutating func getImage() -> ImageFrame? {
        let nextf = self.next()
        count += 1
        if let pxb = nextf?.image {
            let cii = CIImage(cvImageBuffer: pxb)
            if let cgim = convertCIImageToCGImage(cii) {
                let size: CGSize = CGSize(width: 120, height: 100)

                let image = NSImage(cgImage: cgim, size: size)
                return ImageFrame(id:count,image:image)
//                return Image(nsImage: image)
            }
        }
        return nil
    }

}
class AllImages: ObservableObject{
    var fileURL: URL? {
        didSet {
            if let file = fileURL {
                movie = try? PhotogrammetryFrames(fileURL:file)
            }
        }
    }
    var movie:PhotogrammetryFrames? {
        didSet {
            if var ph = movie {
                while let i = ph.getImage() {
                    images.append(i)
                }
            }
        }
    }
    @Published var images: [ImageFrame] = []

    func setAll(flag: Bool){
        
        for i in images.indices {
            images[i].isenabled = flag
        }
    
      
    }
}
struct MovieViewer: View {
    
    @StateObject var Movie = AllImages()
    @State var toggle: Bool = true
    var body: some View {
        let columns: [GridItem] =
                 Array(repeating: .init(.adaptive(minimum: 120)), count: 8)
        VStack{
            HStack{
                Button("Deselect all"){
                    Movie.setAll(flag: false)
                }
                Button("Select all"){
                    Movie.setAll(flag: true)
                }

            }
            ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 10) {
            ForEach($Movie.images){ $im in
                VStack {
                    Image(nsImage: im.image )
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

//#if DEBUG
//struct ContentView_Previews1: PreviewProvider {
//    static var previews: some View {
//        MovieViewer()
//    }
//}
//#endif
