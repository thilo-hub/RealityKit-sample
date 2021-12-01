import SceneKit

struct NodeStack {
    struct element {
        var original:SCNNode
        var clone:SCNNode
      }
    var nodes:[element] = []
    var size: Int {
        get {return nodes.count}
    }
    mutating func push(node: SCNNode) {
        if ( node.geometry != nil) {
            let clone = node.flattenedClone() //  clone()
            nodes.append(element(
                original:node,
                clone:clone
            ))
        }
    }
    mutating func pop() {
        if !nodes.isEmpty {
            let s = nodes.removeLast()
//            s.original = s.clone
            s.original.parent?.replaceChildNode(s.original, with: s.clone)
        }
    }
}

struct NodeStack2 {
    struct element {
        var original:SCNNode
//        var clone:SCNNode
        var pivot: SCNMatrix4
        var transform: SCNMatrix4
    }
    var nodes:[element] = []
    var size: Int {
        get {return nodes.count}
    }
    mutating func push(node: SCNNode) {
        if ( node.geometry != nil) {
//            let clone = node.clone()
            nodes.append(element(
                original:node,
//                clone:clone,
                pivot: node.pivot,
                transform: node.transform
            ))
        }
    }
    mutating func pop() {
        if !nodes.isEmpty {
            let s = nodes.removeLast()
            s.original.transform = s.transform
            s.original.pivot = s.pivot
//            s.original.parent?.replaceChildNode(s.original, with: s.clone)
        }
    }
}
