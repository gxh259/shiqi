import Foundation
@main struct ScheduleTests {
 static func main(){let start=Date(timeIntervalSince1970:1000);var m=WallpaperSchedule()
  m.configure(interval:300,reminder:1800,now:start);assert(m.pairDue==start.addingTimeInterval(300))
  m.configure(interval:300,reminder:1800,now:start.addingTimeInterval(290));assert(m.pairDue==start.addingTimeInterval(300))
  assert(m.takeDue(now:start.addingTimeInterval(299))==nil);assert(m.takeDue(now:start.addingTimeInterval(300)) == .pair)
  assert(m.pairDue==start.addingTimeInterval(600));assert(m.restDue==start.addingTimeInterval(1800))
  assert(m.takeDue(now:start.addingTimeInterval(1700)) == .pair);assert(m.pairDue==start.addingTimeInterval(2000));assert(m.takeDue(now:start.addingTimeInterval(1700))==nil)
  assert(m.takeDue(now:start.addingTimeInterval(1800)) == .rest);assert(m.paused && m.next==nil)
  m.configure(interval:60,reminder:1200,now:start.addingTimeInterval(1801));assert(m.next==nil)
  m.resume(now:start.addingTimeInterval(1980));assert(m.pairDue==start.addingTimeInterval(2040));assert(m.restDue==start.addingTimeInterval(3180))
  m.configure(interval:0,reminder:0,now:start);assert(m.next==nil)
  print("Native schedule: five-minute deadline, settings saves, repeat, wake catch-up, rest priority, pause/resume and disable passed")
 }
}
