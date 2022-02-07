//import UIKit
import SwiftUI
import PlaygroundSupport

import Foundation

var greeting = "Hello, playground"
////
////struct MoviePic: PhotogrammetrySample {
////    var img: PhotogrammetrySample
//////    var imgs: [PhotogrammetrySample] = []
////
////}
////struct MoviePics {
////    var imgs: [MoviePic] = []
////
////}
////
////extension MoviePics:PhotogrammetrySample {
////
////}
//
////extension PhotogrammetrySample {
////    var session
////}
//struct Mx<Element>: IteratorProtocol, Sequence {
//    mutating func next() -> Element? {
//        return nil
//    }
//
//
//
//
//}
//struct Stack<Element> : IteratorProtocol, Sequence {
//    //typealias Element = Int
//    var id: Int
//    var items: [Element] = []
//    init(start: Int){
//        self.id=start
//    }
//    mutating func next() -> Element? {
//        id += 1
//        return items[id]
//
//    }
//    mutating func push(_ item: Element) {
//        items.append(item)
//    }
//    mutating func pop() -> Element {
//        return items.removeLast()
//    }
//}
//
//extension Stack where Element: Equatable {
//    func isTop(_ item: Element) -> Bool {
//        guard let topItem = items.last else {
//            return false
//        }
//        return topItem == item
//    }
//}
//
//var StackOfPhotom = Stack<PhotogrammetrySample>(start: 10)
//
//
//struct ContentView: View {
//  @State var turn:Double = 0
//  var body: some View {
//    return VStack {
//    Image(systemName: "circle")
//      .foregroundColor(Color.blue)
//      .onTapGesture {
//        withAnimation(.linear(duration: 36)) {
//          self.turn = 720
//        }
//      }
//      GlobeView(turn: $turn)
//    } // VStack
//  }
//}
//
//struct GlobeView: View {
// @Binding var turn: Double
//  var body: some View {
//    ZStack {
//      Circle()
//        .stroke(Color.red, lineWidth: 4)
//          .frame(width: 145, height: 145, alignment: .center)
//      Group {
//        ZStack {
//        Text("Center")
//        Ellipse()
//          .stroke(Color.blue, lineWidth: 4)
//          .frame(width: 128, height: 128, alignment: .center)
//        }.rotation3DEffect(.degrees(turn), axis: (x: 1, y: -1, z: 0), anchor: UnitPoint.center, anchorZ: 0, perspective: 0)
//        Ellipse()
//          .stroke(Color.blue, lineWidth: 4)
//          .frame(width: 128, height: 128, alignment: .center)
//          .rotation3DEffect(.degrees(turn+90), axis: (x: -1, y: 1, z: 0), anchor: UnitPoint.center, anchorZ: 0, perspective: 0)
//        Ellipse()
//          .stroke(Color.green, lineWidth: 4)
//          .frame(width: 128, height: 128, alignment: .center)
//          .rotation3DEffect(.degrees(turn), axis: (x: 1, y: 1, z: 0), anchor: UnitPoint.center, anchorZ: 0, perspective: 0)
//        Ellipse()
//          .stroke(Color.green, lineWidth: 4)
//          .frame(width: 128, height: 128, alignment: .center)
//          .rotation3DEffect(.degrees(turn+90), axis: (x: 1, y: 1, z: 0), anchor: UnitPoint.center, anchorZ: 0, perspective: 0)
//        }
//      }
//  }
//}
//

let f1 = "IMG_1668.MOV"

//let f2 = Bundle.main.url(forResource: "IMG_1668", withExtension: "MOV")!
//
//
//print(f2)
//
//var n = 0
//
//var k = try? PhotogrammetryFrames(fileURL: f2)
//
//struct MyView: View {
        
//    var body: some View {
//        ForEach(0..<3) {_ in
//            let sm = k!.next()
//            Image(sm?.image)
//        }
//
//    }
//}

//PlaygroundPage.current.setLiveView(MyView())
