import UIKit

var greeting = "Hello, playground"
//
//struct MoviePic: PhotogrammetrySample {
//    var img: PhotogrammetrySample
////    var imgs: [PhotogrammetrySample] = []
//
//}
//struct MoviePics {
//    var imgs: [MoviePic] = []
//
//}
//
//extension MoviePics:PhotogrammetrySample {
//
//}

//extension PhotogrammetrySample {
//    var session
//}
struct Mx<Element>: IteratorProtocol, Sequence {
    mutating func next() -> Element? {
        return nil
    }
    

    
    
}
struct Stack<Element> : IteratorProtocol, Sequence {
    //typealias Element = Int
    var id: Int
    var items: [Element] = []
    init(start: Int){
        self.id=start
    }
    mutating func next() -> Element? {
        id += 1
        return items[id]
    
    }
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
}

extension Stack where Element: Equatable {
    func isTop(_ item: Element) -> Bool {
        guard let topItem = items.last else {
            return false
        }
        return topItem == item
    }
}

var StackOfPhotom = Stack<PhotogrammetrySample>(start: 10)
