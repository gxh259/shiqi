import Cocoa
// A backing surface for the single WebKit state engine; user interfaces live in popovers.
final class HiddenEngineWindow:NSWindow {
 override var canBecomeKey:Bool{false}
 override var canBecomeMain:Bool{false}
 override func order(_ place:NSWindow.OrderingMode,relativeTo otherWin:Int){if place == .out{super.order(place,relativeTo:otherWin)}}
}
