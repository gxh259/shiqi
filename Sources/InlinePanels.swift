import Cocoa
import WebKit
extension Delegate:NSPopoverDelegate,NSMenuDelegate {
 func runWeb(_ script:String){guard webReady else{pendingWeb.append(script);return};web.evaluateJavaScript(script,completionHandler:nil)}
 func showInlinePanel(_ type:String){
  guard webReady else{pendingPanel=type;return}
  if restOverlay.isActive{restOverlay.finish()}
  feedbackPopover?.close()
  let value=String(data:try! JSONSerialization.data(withJSONObject:[type]),encoding:.utf8)!
  let script="document.body.classList.add('menu-panel');openPanel(\(value)[0]);"
  web.evaluateJavaScript(script){[weak self] _,error in
   guard let self=self,error==nil else{return}
   if self.isValidationRun && !CommandLine.arguments.contains("--interaction-test"){return}
   self.window.orderOut(nil)
   if self.inlinePopover.isShown{return}
   self.web.removeFromSuperview();self.window.contentView=NSView()
   let controller=NSViewController();let content=NSView(frame:NSRect(x:0,y:0,width:600,height:540));self.web.frame=content.bounds;self.web.autoresizingMask=[.width,.height];content.addSubview(self.web);controller.view=content
   self.inlinePopover.contentViewController=controller;self.inlinePopover.contentSize=content.frame.size;self.inlinePopover.behavior = .transient;self.inlinePopover.animates=false;self.inlinePopover.delegate=self
   if let button=self.status.button{NSApp.activate(ignoringOtherApps:true);self.inlinePopover.show(relativeTo:button.bounds,of:button,preferredEdge:.minY);self.inlinePopover.contentViewController?.view.window?.makeFirstResponder(self.web)}
  }
 }
 func closeInlinePanel(){inlinePopover.performClose(nil)}
 func popoverDidClose(_ notification:Notification){guard notification.object as? NSPopover === inlinePopover else{return};web.removeFromSuperview();window.contentView=web;web.frame=window.contentView!.bounds;web.evaluateJavaScript("if(dialog.open)dialog.close();",completionHandler:nil)}
 func showFeedback(_ message:String){
  guard !isValidationRun else{return}
  if inlinePopover.isShown{return}
  DispatchQueue.main.async{[weak self] in guard let self=self,let button=self.status.button else{return};self.feedbackPopover?.close();let popover=NSPopover();let vc=NSViewController();let view=NSView(frame:NSRect(x:0,y:0,width:280,height:70));let label=NSTextField(wrappingLabelWithString:message);label.frame=NSRect(x:18,y:14,width:244,height:42);label.alignment = .center;view.addSubview(label);vc.view=view;popover.contentViewController=vc;popover.contentSize=view.frame.size;popover.behavior = .transient;popover.animates=false;self.feedbackPopover=popover;popover.show(relativeTo:button.bounds,of:button,preferredEdge:.minY);DispatchQueue.main.asyncAfter(deadline:.now()+2){[weak popover] in popover?.close()}}
 }
 func screensMenu()->NSMenuItem{let item=NSMenuItem(title:"选择显示器",action:nil,keyEquivalent:"");let menu=NSMenu();menu.identifier=NSUserInterfaceItemIdentifier("screen-picker");menu.delegate=self;item.submenu=menu;populateScreens(menu);return item}
 func populateScreens(_ menu:NSMenu){menu.removeAllItems();for (index,screen) in NSScreen.screens.enumerated(){let item=actionItem("\(index==0 ? "主屏幕" : "显示器 \(index+1)") · \(screen.localizedName)","screen:\(index)");item.state=index==screenIndex ? .on:.off;menu.addItem(item)}}
 func menuNeedsUpdate(_ menu:NSMenu){if menu.identifier?.rawValue=="screen-picker"{populateScreens(menu)}}
 func chooseScreen(_ index:Int){guard NSScreen.screens.indices.contains(index) else{return};screenIndex=index;UserDefaults.standard.set(index,forKey:"screenIndex");updateDesktop();let screen=NSScreen.screens[index];for window in videoWindows{window.setFrame(screen.frame,display:true)};refreshVideoText();showFeedback("已切换到 \(NSScreen.screens[index].localizedName)")}
}
