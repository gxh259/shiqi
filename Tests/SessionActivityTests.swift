import Cocoa
@main struct SessionTests {
 static func main(){
  _=NSApplication.shared
  let workspace=NotificationCenter(),distributed=NotificationCenter();var locked=false;var rests=0;var pairs=0
  let schedule=NativeSchedule(onPair:{pairs+=1},onRest:{rests+=1})
  let monitor=SessionActivityMonitor(workspace:workspace,distributed:distributed,unavailable:{locked},onChange:{schedule.suppressRest($0)})
  schedule.restAllowed={monitor.isAvailable}
  func advance(_ seconds:TimeInterval){RunLoop.main.run(until:Date().addingTimeInterval(seconds))}
  schedule.configure(interval:0.15,reminder:0.2)
  locked=true;distributed.post(name:NSNotification.Name("com.apple.screenIsLocked"),object:nil)
  assert(schedule.model.restDue==nil);let pairDue=schedule.model.pairDue;assert(pairDue != nil)
  schedule.configure(interval:0.15,reminder:0.3);assert(schedule.model.restDue==nil)
  advance(0.9);assert(rests==0 && pairs>0)
  locked=false;let unlockedAt=Date();distributed.post(name:NSNotification.Name("com.apple.screenIsUnlocked"),object:nil)
  assert(schedule.model.restDue!>=unlockedAt.addingTimeInterval(0.3));assert(!schedule.model.paused)
  advance(0.9);assert(rests==1)
  schedule.resume();schedule.configure(interval:0,reminder:0.15)
  // A direct session query blocks a race even before a lock notification arrives.
  locked=true;advance(0.9);assert(rests==1 && schedule.model.restDue==nil)
  locked=false;distributed.post(name:NSNotification.Name("com.apple.screenIsUnlocked"),object:nil)
  assert(schedule.model.restDue != nil);advance(0.9);assert(rests==2)
  schedule.resume();workspace.post(name:NSWorkspace.willSleepNotification,object:nil);assert(schedule.model.restDue==nil)
  workspace.post(name:NSWorkspace.didWakeNotification,object:nil);assert(schedule.model.restDue != nil)
  workspace.post(name:NSWorkspace.sessionDidResignActiveNotification,object:nil);assert(schedule.model.restDue==nil)
  workspace.post(name:NSWorkspace.sessionDidBecomeActiveNotification,object:nil);assert(schedule.model.restDue != nil)
  workspace.post(name:NSWorkspace.screensDidSleepNotification,object:nil);assert(schedule.model.restDue==nil)
  workspace.post(name:NSWorkspace.screensDidWakeNotification,object:nil);assert(schedule.model.restDue != nil)
  let restarted=schedule.model.restDue;distributed.post(name:NSNotification.Name("com.apple.screenIsUnlocked"),object:nil);assert(schedule.model.restDue==restarted)
  schedule.configure(interval:0,reminder:0)
  print("Session activity: locked suppression, wallpaper continuation, unlock restart, missed-notification race, sleep, session switch and duplicate events passed")
 }
}
