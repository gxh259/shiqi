import Cocoa
final class NativeSchedule {
 var model=WallpaperSchedule();var timer:Timer?;var activity:NSObjectProtocol?;var observers:[NSObjectProtocol]=[]
 var restAllowed:()->Bool={true}
 let onPair:()->Void;let onRest:()->Void
 init(onPair:@escaping ()->Void,onRest:@escaping ()->Void){self.onPair=onPair;self.onRest=onRest
  for name in [NSWorkspace.didWakeNotification,NSWorkspace.screensDidWakeNotification]{observers.append(NSWorkspace.shared.notificationCenter.addObserver(forName:name,object:nil,queue:.main){[weak self] _ in self?.fire()})}
 }
 deinit{timer?.invalidate();if let activity=activity{ProcessInfo.processInfo.endActivity(activity)};for observer in observers{NSWorkspace.shared.notificationCenter.removeObserver(observer)}}
 func configure(interval:TimeInterval,reminder:TimeInterval){model.configure(interval:interval,reminder:reminder);arm()}
 func suppressRest(_ suppressed:Bool){model.suppressRest(suppressed);arm()}
 func pause(){model.pause();arm()}
 func resume(){model.resume();arm()}
 func arm(){timer?.invalidate();timer=nil
  if let date=model.next{
   if activity==nil{activity=ProcessInfo.processInfo.beginActivity(options:.userInitiatedAllowingIdleSystemSleep,reason:"按用户设置自动切换桌面诗画与提醒休息")}
   let timer=Timer(fire:date,interval:0,repeats:false){[weak self] _ in self?.fire()};timer.tolerance=0.5;self.timer=timer;RunLoop.main.add(timer,forMode:.common)
  }else if let activity=activity{ProcessInfo.processInfo.endActivity(activity);self.activity=nil}
 }
 func fire(){model.suppressRest(!restAllowed());let event=model.takeDue();arm();switch event{case .pair:onPair();case .rest:onRest();case nil:break}}
}
