import Foundation
// Deadlines survive ordinary settings saves and catch up once after sleep.
struct WallpaperSchedule {
 enum Event {case pair,rest}
 var interval:TimeInterval=0;var reminder:TimeInterval=0;var paused=false
 var pairDue:Date?;var restDue:Date?;var restSuppressed=false
 mutating func configure(interval:TimeInterval,reminder:TimeInterval,now:Date=Date()){
  let interval=max(0,interval),reminder=max(0,reminder)
  if self.interval != interval{self.interval=interval;pairDue = !paused && interval>0 ? now.addingTimeInterval(interval):nil}
  if self.reminder != reminder{self.reminder=reminder;restDue = !paused && !restSuppressed && reminder>0 ? now.addingTimeInterval(reminder):nil}
 }
 mutating func pause(){paused=true;pairDue=nil;restDue=nil}
 mutating func resume(now:Date=Date()){guard paused else{return};paused=false;pairDue=interval>0 ? now.addingTimeInterval(interval):nil;restDue=reminder>0 && !restSuppressed ? now.addingTimeInterval(reminder):nil}
 mutating func suppressRest(_ suppressed:Bool,now:Date=Date()){guard restSuppressed != suppressed else{return};restSuppressed=suppressed;restDue = !suppressed && !paused && reminder>0 ? now.addingTimeInterval(reminder):nil}
 var next:Date?{[pairDue,restDue].compactMap{$0}.min()}
 mutating func takeDue(now:Date=Date())->Event?{
  guard !paused else{return nil}
  if !restSuppressed,let due=restDue,due<=now{pause();return .rest}
  if let due=pairDue,due<=now{pairDue=now.addingTimeInterval(interval);return .pair}
  return nil
 }
}
