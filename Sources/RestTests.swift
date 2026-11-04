import Cocoa
extension Delegate {
 func runRestSelfTest(){
  var finished=0;let c=RestOverlayController{finished+=1}
  let frames=[NSRect(x:0,y:0,width:1280,height:800),NSRect(x:-1024,y:0,width:1024,height:768)]
  c.start(seconds:60,image:lastImage,poem:poemText,present:false,frames:frames)
  assert(c.windows.count==2);assert(c.windows.map{$0.frame}==frames);assert(c.windows.allSatisfy{$0.level.rawValue==Int(CGWindowLevelForKey(.screenSaverWindow))})
  assert(c.countdownLabels.allSatisfy{$0.stringValue=="01:00"});c.tick(now:c.countdown!.deadline.addingTimeInterval(-12.5));assert(c.countdownLabels.allSatisfy{$0.stringValue=="00:13"})
  c.finish();c.finish();assert(finished==1 && c.windows.isEmpty && c.timer==nil)
  c.start(seconds:60,image:nil,poem:"",present:false,frames:frames);c.tick(now:c.countdown!.deadline.addingTimeInterval(1));assert(finished==2 && !c.isActive)
  c.startScreensaver(image:nil,poem:"",present:false,frames:frames);assert(c.isActive && c.mode == .screensaver && c.countdown==nil && c.timer==nil && c.windows.count==2 && c.countdownLabels.isEmpty);c.finish();assert(finished==3)
  c.start(seconds:1,image:nil,poem:"",present:false,frames:frames)
  DispatchQueue.main.asyncAfter(deadline:.now()+1.6){
   assert(finished==4 && !c.isActive && c.windows.isEmpty)
   let preview=RestOverlayController{};preview.start(seconds:300,image:self.lastImage,poem:self.poemText,present:false,frames:[NSScreen.main!.frame]);let view=preview.windows[0].contentView!;view.layoutSubtreeIfNeeded()
   if let bitmap=view.bitmapImageRepForCachingDisplay(in:view.bounds){view.cacheDisplay(in:view.bounds,to:bitmap);if let png=bitmap.representation(using:.png,properties:[:]){try? png.write(to:URL(fileURLWithPath:FileManager.default.currentDirectoryPath+"/outputs/休息屏保预览.png"))}}
   preview.finish()
   print("{\"success\":true,\"checks\":[\"two-screen frame coverage\",\"screen saver window level\",\"synchronized countdown\",\"early exit and timer cleanup\",\"deadline exit\",\"real timer automatic exit\"]}");fflush(stdout);NSApp.terminate(nil)
  }
 }
}
