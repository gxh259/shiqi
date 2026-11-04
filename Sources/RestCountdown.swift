import Foundation
struct RestCountdown {
 let deadline:Date
 init(seconds:Int,now:Date=Date()){deadline=now.addingTimeInterval(TimeInterval(max(1,min(seconds,3600))))}
 func remaining(at now:Date=Date())->Int{max(0,Int(ceil(deadline.timeIntervalSince(now))))}
 static func display(_ seconds:Int)->String {String(format:"%02d:%02d",max(0,seconds)/60,max(0,seconds)%60)}
}
