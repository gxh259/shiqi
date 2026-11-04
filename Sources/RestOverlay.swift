import Cocoa

final class RestScreenWindow:NSWindow {
 override var canBecomeKey:Bool{true}
 override var canBecomeMain:Bool{true}
}
final class RestBackdrop:NSView {
 let image:NSImage?
 init(frame:NSRect,image:NSImage?){self.image=image;super.init(frame:frame)}
 required init?(coder:NSCoder){fatalError("Not used")}
 override func draw(_ dirtyRect:NSRect){
  NSColor(calibratedRed:0.06,green:0.16,blue:0.17,alpha:1).setFill();bounds.fill()
  if let image=image,image.size.width>0,image.size.height>0 {let scale=max(bounds.width/image.size.width,bounds.height/image.size.height);let rect=NSRect(x:(bounds.width-image.size.width*scale)/2,y:(bounds.height-image.size.height*scale)/2,width:image.size.width*scale,height:image.size.height*scale);image.draw(in:rect,from:.zero,operation:.sourceOver,fraction:1)}
  NSColor.black.withAlphaComponent(0.42).setFill();bounds.fill()
 }
}
final class RestOverlayController:NSObject {
 var windows:[NSWindow]=[];var countdownLabels:[NSTextField]=[];var countdown:RestCountdown?;var timer:Timer?
 var previousApp:NSRunningApplication?;var observer:Any?;var keyMonitor:Any?;let onFinish:()->Void
 var image:NSImage?;var poem=""
 var isActive:Bool{countdown != nil}
 init(onFinish:@escaping ()->Void){self.onFinish=onFinish;super.init();observer=NotificationCenter.default.addObserver(forName:NSApplication.didChangeScreenParametersNotification,object:nil,queue:.main){[weak self] _ in guard let self=self,self.isActive else{return};self.buildWindows(frames:NSScreen.screens.map{$0.frame},present:true)}}
 deinit{timer?.invalidate();if let observer=observer{NotificationCenter.default.removeObserver(observer)};if let keyMonitor=keyMonitor{NSEvent.removeMonitor(keyMonitor)}}
 func start(seconds:Int,image:NSImage?,poem:String,present:Bool=true,frames:[NSRect]?=nil){
  guard !isActive else{if present{windows.forEach{$0.orderFrontRegardless()}};return}
  self.image=image;self.poem=poem;countdown=RestCountdown(seconds:seconds);previousApp=present ? NSWorkspace.shared.frontmostApplication:nil
  buildWindows(frames:frames ?? NSScreen.screens.map{$0.frame},present:present)
  guard !windows.isEmpty else{finish();return}
  keyMonitor=NSEvent.addLocalMonitorForEvents(matching:.keyDown){[weak self] event in guard event.keyCode==53,self?.isActive==true else{return event};self?.finish();return nil}
  let ticker=Timer(timeInterval:0.25,repeats:true){[weak self] _ in self?.tick()};timer=ticker;RunLoop.main.add(ticker,forMode:.common);tick()
 }
 func label(_ text:String,font:NSFont,color:NSColor=NSColor(calibratedWhite:0.98,alpha:1))->NSTextField {let view=NSTextField(wrappingLabelWithString:text);view.font=font;view.textColor=color;view.alignment = .center;view.maximumNumberOfLines=4;view.translatesAutoresizingMaskIntoConstraints=false;return view}
 func buildWindows(frames:[NSRect],present:Bool){
  windows.forEach{$0.orderOut(nil);$0.close()};windows=[];countdownLabels=[]
  for frame in frames {
   let w=RestScreenWindow(contentRect:frame,styleMask:.borderless,backing:.buffered,defer:false);w.isReleasedWhenClosed=false;w.hasShadow=false;w.level=NSWindow.Level(rawValue:Int(CGWindowLevelForKey(.screenSaverWindow)));w.collectionBehavior=[.canJoinAllSpaces,.fullScreenAuxiliary,.stationary,.ignoresCycle];w.backgroundColor = .black
   let view=RestBackdrop(frame:NSRect(origin:.zero,size:frame.size),image:image);w.contentView=view
   let title=label("让眼睛放个假",font:NSFont(name:"Songti SC",size:36) ?? .systemFont(ofSize:36))
   let subtitle=label("砖会一直有，先把自己照顾好。",font:.systemFont(ofSize:16),color:NSColor(calibratedWhite:0.95,alpha:0.85))
   let caption=label("休息倒计时",font:.systemFont(ofSize:13,weight:.medium),color:NSColor(calibratedWhite:0.95,alpha:0.8))
   let digits=label(RestCountdown.display(countdown?.remaining() ?? 0),font:.monospacedDigitSystemFont(ofSize:76,weight:.ultraLight));digits.setAccessibilityIdentifier("rest-countdown");countdownLabels.append(digits)
   let excerpt=poem.split(separator:"\n",omittingEmptySubsequences:true).prefix(4).joined(separator:"\n")
   let poetry=label(String(excerpt.prefix(180)),font:NSFont(name:"Songti SC",size:19) ?? .systemFont(ofSize:19),color:NSColor(calibratedWhite:0.98,alpha:0.9))
   let button=NSButton(title:"继续搬砖",target:self,action:#selector(finish));button.bezelStyle = .rounded;button.controlSize = .large;button.font = .systemFont(ofSize:16,weight:.medium);button.translatesAutoresizingMaskIntoConstraints=false;button.setAccessibilityIdentifier("rest-resume")
   let hint=label("按 Esc 也能返回 · 倒计时结束自动收工",font:.systemFont(ofSize:12),color:NSColor(calibratedWhite:1,alpha:0.65))
   let stack=NSStackView(views:[title,subtitle,caption,digits,poetry,button,hint]);stack.orientation = .vertical;stack.alignment = .centerX;stack.spacing=16;stack.setCustomSpacing(30,after:subtitle);stack.setCustomSpacing(25,after:digits);stack.setCustomSpacing(28,after:poetry);stack.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(stack)
   NSLayoutConstraint.activate([stack.centerXAnchor.constraint(equalTo:view.centerXAnchor),stack.centerYAnchor.constraint(equalTo:view.centerYAnchor),stack.widthAnchor.constraint(equalTo:view.widthAnchor,multiplier:0.78),button.widthAnchor.constraint(equalToConstant:180),button.heightAnchor.constraint(greaterThanOrEqualToConstant:38)])
   for text in [title,subtitle,caption,digits,poetry,hint]{text.widthAnchor.constraint(lessThanOrEqualTo:stack.widthAnchor).isActive=true}
   windows.append(w);if present{w.orderFrontRegardless()}
  }
  if present{NSApp.activate(ignoringOtherApps:true);windows.first?.makeKeyAndOrderFront(nil)}
 }
 func tick(now:Date=Date()){guard let countdown=countdown else{return};let remaining=countdown.remaining(at:now);countdownLabels.forEach{$0.stringValue=RestCountdown.display(remaining)};if remaining==0{finish()}}
 @objc func finish(){guard isActive else{return};timer?.invalidate();timer=nil;countdown=nil;if let keyMonitor=keyMonitor{NSEvent.removeMonitor(keyMonitor);self.keyMonitor=nil};windows.forEach{$0.orderOut(nil);$0.close()};windows=[];countdownLabels=[];image=nil;onFinish();if let app=previousApp,app.processIdentifier != ProcessInfo.processInfo.processIdentifier{app.activate(options:[])};previousApp=nil}
}
