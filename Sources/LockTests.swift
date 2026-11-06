import Cocoa
extension Delegate {
 func runLockTests(){
  let workspace=NotificationCenter(),distributed=NotificationCenter();var locked=true
  sessionActivity=SessionActivityMonitor(workspace:workspace,distributed:distributed,unavailable:{locked},onChange:{[weak self] blocked in self?.sessionAvailabilityChanged(blocked)})
  sessionAvailabilityChanged(true);nativeSchedule.configure(interval:300,reminder:1200)
  perform("rest");assert(!restOverlay.isActive && restOverlay.windows.isEmpty && nativeSchedule.model.restDue==nil)
  assert(!nativeSchedule.model.paused && nativeSchedule.model.pairDue != nil)
  locked=false;distributed.post(name:NSNotification.Name("com.apple.screenIsUnlocked"),object:nil)
  let deadline=nativeSchedule.model.restDue;assert(deadline != nil && deadline!.timeIntervalSinceNow>1195)
  nativeSchedule.pause();restOverlay.start(seconds:60,image:lastImage,poem:poemText,present:false,frames:[NSRect(x:0,y:0,width:1280,height:800)])
  locked=true;distributed.post(name:NSNotification.Name("com.apple.screenIsLocked"),object:nil)
  assert(!restOverlay.isActive && restOverlay.windows.isEmpty && restOverlay.previousApp==nil)
  assert(nativeSchedule.model.restDue==nil && !nativeSchedule.model.paused && nativeSchedule.model.pairDue != nil)
  nativeSchedule.configure(interval:0,reminder:0)
  print("{\"success\":true,\"checks\":[\"locked rest action creates no windows\",\"unlock starts a complete reminder interval\",\"locking dismisses existing rest without restoring app focus\",\"wallpaper schedule continues\"]}");fflush(stdout);NSApp.terminate(nil)
 }
}
