import SwiftUI
import SceneKit
//import Kit
#if false
class NFingerGestureRecognizer: NSGestureRecognizer {

    var tappedCallback: (NSTouch, CGPoint?) -> Void

    var touchViews = [NSTouch:CGPoint]()

    init(target: Any?, tappedCallback: @escaping (NSTouch, CGPoint?) -> ()) {
        self.tappedCallback = tappedCallback
        super.init(target: target, action: nil)
    }

    override func touchesBegan(_ touches: Set<NSTouch>, with event: NSEvent) {
        for touch in touches {
            let location = touch.location(in: touch.view)
            print("Start: (\(location.x)/\(location.y))")
            touchViews[touch] = location
        }
    }

    override func touchesMoved(_ touches: Set<NSTouch>, with event: NSEvent) {
        for touch in touches {
            let oldLocation = touchViews[touch]!
            let newLocation = touch.location(in: touch.view)
            touchViews[touch] = newLocation
            print("Move: (\(oldLocation.x)/\(oldLocation.y)) -> (\(newLocation.x)/\(newLocation.y))")
        }
    }

    override func touchesEnded(_ touches: Set<NSTouch>, with event: NSEvent) {
        for touch in touches {
            let oldLocation = touchViews[touch]!
            touchViews.removeValue(forKey: touch)
            print("End: (\(oldLocation.x)/\(oldLocation.y))")
        }
    }

}
#endif
