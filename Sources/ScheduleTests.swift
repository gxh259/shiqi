import Cocoa
extension Delegate {
 func runScheduleTests(){
  assert(!window.isVisible);var checks:[String]=[]
  web.evaluateJavaScript("JSON.stringify({p:state.p,w:state.w})"){before,error in
   assert(error==nil);let before=before as! String
   self.nativeSchedule.configure(interval:1.2,reminder:0)
   let deadline=self.nativeSchedule.model.pairDue
   DispatchQueue.main.asyncAfter(deadline:.now()+0.5){self.nativeSchedule.configure(interval:1.2,reminder:0);assert(self.nativeSchedule.model.pairDue==deadline)}
   DispatchQueue.main.asyncAfter(deadline:.now()+2){
    self.nativeSchedule.configure(interval:0,reminder:0)
    self.web.evaluateJavaScript("JSON.stringify({p:state.p,w:state.w})"){after,error in
     assert(error==nil && before != after as? String && !self.window.isVisible)
     checks.append("native timer changes poetry and wallpaper with host hidden")
     checks.append("unchanged settings do not postpone deadline")
     self.nativeSchedule.configure(interval:1,reminder:0);self.nativeSchedule.pause()
     let paused=after as! String
     DispatchQueue.main.asyncAfter(deadline:.now()+1.3){
      self.web.evaluateJavaScript("JSON.stringify({p:state.p,w:state.w})"){value,error in
       assert(value as? String==paused);checks.append("rest pauses native switch")
       self.nativeSchedule.resume()
       DispatchQueue.main.asyncAfter(deadline:.now()+1.5){
        self.nativeSchedule.configure(interval:0,reminder:0)
        self.web.evaluateJavaScript("JSON.stringify({p:state.p,w:state.w})"){value,error in
         assert(value as? String != paused);checks.append("return from rest resumes switch")
         let data=try! JSONSerialization.data(withJSONObject:["success":true,"checks":checks]);print(String(data:data,encoding:.utf8)!);fflush(stdout);NSApp.terminate(nil)
        }
       }
      }
     }
    }
   }
  }
 }
}
