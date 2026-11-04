import Cocoa
extension Delegate {
 func runInteractionTests(){
  assert(!window.isVisible)
  menuAction(actionItem("切换诗歌","poem"));applySetting("size","26")
  assert(!window.isVisible)
  showInlinePanel("search")
  DispatchQueue.main.asyncAfter(deadline:.now()+1){
   assert(self.inlinePopover.isShown && !self.window.isVisible)
   self.web.evaluateJavaScript("document.body.classList.contains('menu-panel') && dialog.open && !!document.getElementById('query')"){value,error in
    assert(error==nil && value as? Bool==true)
    self.closeInlinePanel()
    DispatchQueue.main.asyncAfter(deadline:.now()+0.2){
     assert(!self.inlinePopover.isShown && !self.window.isVisible)
     let frames=[NSRect(x:0,y:0,width:1280,height:800),NSRect(x:-1024,y:0,width:1024,height:768)]
     let saver=RestOverlayController{};saver.startScreensaver(image:self.lastImage,poem:self.poemText,present:false,frames:frames)
     assert(saver.isActive && saver.mode == .screensaver && saver.windows.count==2 && saver.countdown==nil && saver.timer==nil)
     assert(saver.windows.allSatisfy{$0.styleMask == .borderless && $0.level.rawValue==Int(CGWindowLevelForKey(.screenSaverWindow))})
     saver.finish();assert(!self.window.isVisible)
     print("{\"success\":true,\"checks\":[\"direct menu actions keep host hidden\",\"search opens anchored popover only\",\"popover closes without app window\",\"borderless screen saver covers both screen frames\",\"manual screen saver has no rest timer\"]}");fflush(stdout);NSApp.terminate(nil)
    }
   }
  }
 }
}
