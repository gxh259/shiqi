import Cocoa
import CoreGraphics
// Observe session changes without locking the computer or requiring Accessibility access.
final class SessionActivityMonitor:NSObject {
 let workspace:NotificationCenter;let distributed:NotificationCenter;let unavailable:()->Bool;let onChange:(Bool)->Void
 var locked:Bool;var inactive=false;var sleeping=false;var displaySleeping=false;var reported:Bool
 static func systemUnavailable()->Bool{
  guard let session=CGSessionCopyCurrentDictionary() as? [String:Any] else{return true}
  let locked=(session["CGSSessionScreenIsLocked"] as? Bool) ?? false
  let onConsole=(session[kCGSessionOnConsoleKey as String] as? Bool) ?? false
  return locked || !onConsole
 }
 var isAvailable:Bool{!locked && !inactive && !sleeping && !displaySleeping && !unavailable()}
 init(workspace:NotificationCenter=NSWorkspace.shared.notificationCenter,distributed:NotificationCenter=DistributedNotificationCenter.default(),unavailable:@escaping ()->Bool=SessionActivityMonitor.systemUnavailable,onChange:@escaping (Bool)->Void){
  self.workspace=workspace;self.distributed=distributed;self.unavailable=unavailable;self.onChange=onChange;let blocked=unavailable();locked=blocked;reported=blocked;super.init()
  for name in ["com.apple.screenIsLocked","com.apple.screenIsUnlocked"]{distributed.addObserver(self,selector:#selector(receive(_:)),name:NSNotification.Name(name),object:nil)}
  for name in [NSWorkspace.sessionDidResignActiveNotification,NSWorkspace.sessionDidBecomeActiveNotification,NSWorkspace.willSleepNotification,NSWorkspace.didWakeNotification,NSWorkspace.screensDidSleepNotification,NSWorkspace.screensDidWakeNotification]{workspace.addObserver(self,selector:#selector(receive(_:)),name:name,object:nil)}
 }
 deinit{workspace.removeObserver(self);distributed.removeObserver(self)}
 @objc private func receive(_ notification:Notification){
  guard Thread.isMainThread else{DispatchQueue.main.async{[weak self] in self?.receive(notification)};return}
  switch notification.name {
  case NSNotification.Name("com.apple.screenIsLocked"):locked=true
  case NSNotification.Name("com.apple.screenIsUnlocked"):locked=false
  case NSWorkspace.sessionDidResignActiveNotification:inactive=true
  case NSWorkspace.sessionDidBecomeActiveNotification:inactive=false;locked=unavailable()
  case NSWorkspace.willSleepNotification:sleeping=true
  case NSWorkspace.didWakeNotification:sleeping=false
  case NSWorkspace.screensDidSleepNotification:displaySleeping=true
  case NSWorkspace.screensDidWakeNotification:displaySleeping=false
  default:return
  }
  // Unlock is authoritative here; the direct session query is also checked at execution time.
  let blocked=locked || inactive || sleeping || displaySleeping
  reported=blocked;onChange(blocked)
 }
}
