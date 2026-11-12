import Cocoa
import AVFoundation

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
 enum Mode{case rest,screensaver};var mode:Mode?
 var windows:[NSWindow]=[];var countdownLabels:[NSTextField]=[];var countdown:RestCountdown?;var timer:Timer?
 var previousApp:NSRunningApplication?;var observer:Any?;var keyMonitor:Any?;let onFinish:()->Void
 var videoOverride:URL?;var videoPlayers:[AVQueuePlayer]=[];var videoLoopers:[AVPlayerLooper]=[]
 var image:NSImage?;var poem=""
 var isActive:Bool{mode != nil}
 init(onFinish:@escaping ()->Void){self.onFinish=onFinish;super.init();observer=NotificationCenter.default.addObserver(forName:NSApplication.didChangeScreenParametersNotification,object:nil,queue:.main){[weak self] _ in guard let self=self,self.isActive else{return};self.buildWindows(frames:NSScreen.screens.map{$0.frame},present:true)}}
 deinit{timer?.invalidate();if let observer=observer{NotificationCenter.default.removeObserver(observer)};if let keyMonitor=keyMonitor{NSEvent.removeMonitor(keyMonitor)}}
 func start(seconds:Int,image:NSImage?,poem:String,present:Bool=true,frames:[NSRect]?=nil){begin(mode:.rest,seconds:seconds,image:image,poem:poem,present:present,frames:frames)}
 func startScreensaver(image:NSImage?,poem:String,present:Bool=true,frames:[NSRect]?=nil){begin(mode:.screensaver,seconds:nil,image:image,poem:poem,present:present,frames:frames)}
 private func begin(mode:Mode,seconds:Int?,image:NSImage?,poem:String,present:Bool,frames:[NSRect]?){
  guard !isActive else{if present{windows.forEach{$0.orderFrontRegardless()}};return}
  self.mode=mode;self.image=image;self.poem=poem;countdown=seconds.map{RestCountdown(seconds:$0)};previousApp=present ? NSWorkspace.shared.frontmostApplication:nil
  buildWindows(frames:frames ?? NSScreen.screens.map{$0.frame},present:present)
  guard !windows.isEmpty else{finish();return}
  keyMonitor=NSEvent.addLocalMonitorForEvents(matching:.keyDown){[weak self] event in guard event.keyCode==53,self?.isActive==true else{return event};self?.finish();return nil}
  if mode == .rest {let ticker=Timer(timeInterval:0.25,repeats:true){[weak self] _ in self?.tick()};timer=ticker;RunLoop.main.add(ticker,forMode:.common);tick()}
 }
 func updateScene(image:NSImage?,poem:String){self.image=image;self.poem=poem;if isActive{buildWindows(frames:NSScreen.screens.map{$0.frame},present:true)}}
 func label(_ text:String,font:NSFont,color:NSColor=NSColor(calibratedWhite:0.98,alpha:1))->NSTextField {let view=NSTextField(wrappingLabelWithString:text);view.font=font;view.textColor=color;view.alignment = .center;view.maximumNumberOfLines=4;view.translatesAutoresizingMaskIntoConstraints=false;return view}
 func buildWindows(frames:[NSRect],present:Bool){
  stopVideo();windows.forEach{$0.orderOut(nil);$0.close()};windows=[];countdownLabels=[]
  for frame in frames {
   let w=RestScreenWindow(contentRect:frame,styleMask:.borderless,backing:.buffered,defer:false);w.isReleasedWhenClosed=false;w.hasShadow=false;w.level=NSWindow.Level(rawValue:Int(CGWindowLevelForKey(.screenSaverWindow)));w.collectionBehavior=[.canJoinAllSpaces,.fullScreenAuxiliary,.stationary,.ignoresCycle];w.backgroundColor = .black
   let view=RestBackdrop(frame:NSRect(origin:.zero,size:frame.size),image:image);w.contentView=view
   if let url=videoOverride ?? ScreenSaverVideo.configuredURL{let video=NSView(frame:view.bounds);video.autoresizingMask=[.width,.height];video.wantsLayer=true;let player=AVQueuePlayer();player.isMuted=true;let looper=AVPlayerLooper(player:player,templateItem:AVPlayerItem(url:url));let layer=AVPlayerLayer(player:player);layer.frame=video.bounds;layer.autoresizingMask=[.layerWidthSizable,.layerHeightSizable];layer.videoGravity = .resizeAspectFill;video.layer?.addSublayer(layer);let shade=CALayer();shade.frame=video.bounds;shade.autoresizingMask=[.layerWidthSizable,.layerHeightSizable];shade.backgroundColor=NSColor.black.withAlphaComponent(0.35).cgColor;video.layer?.addSublayer(shade);view.addSubview(video);videoPlayers.append(player);videoLoopers.append(looper);player.play()}
   let title=label(mode == .rest ? "让眼睛放个假" : "一屏山水，一首诗",font:NSFont(name:"Songti SC",size:36) ?? .systemFont(ofSize:36))
   let subtitle=label(mode == .rest ? "砖会一直有，先把自己照顾好。" : "偷得浮生半日闲。",font:.systemFont(ofSize:16),color:NSColor(calibratedWhite:0.95,alpha:0.85))
   let caption=label("休息倒计时",font:.systemFont(ofSize:13,weight:.medium),color:NSColor(calibratedWhite:0.95,alpha:0.8))
   let digits=label(RestCountdown.display(countdown?.remaining() ?? 0),font:.monospacedDigitSystemFont(ofSize:76,weight:.ultraLight));digits.setAccessibilityIdentifier("rest-countdown");if mode == .rest{countdownLabels.append(digits)}
   let excerpt=poem.split(separator:"\n",omittingEmptySubsequences:true).prefix(4).joined(separator:"\n")
   let poetry=label(String(excerpt.prefix(180)),font:NSFont(name:"Songti SC",size:19) ?? .systemFont(ofSize:19),color:NSColor(calibratedWhite:0.98,alpha:0.9))
   let button=NSButton(title:"继续搬砖",target:self,action:#selector(finish));button.bezelStyle = .rounded;button.controlSize = .large;button.font = .systemFont(ofSize:16,weight:.medium);button.translatesAutoresizingMaskIntoConstraints=false;button.setAccessibilityIdentifier("rest-resume")
   let hint=label(mode == .rest ? "按 Esc 也能返回 · 倒计时结束自动返回" : "按 Esc 返回桌面，或点击继续搬砖",font:.systemFont(ofSize:12),color:NSColor(calibratedWhite:1,alpha:0.65))
   let views:[NSView]=mode == .rest ? [title,subtitle,caption,digits,poetry,button,hint] : [title,subtitle,poetry,button,hint];let stack=NSStackView(views:views);stack.orientation = .vertical;stack.alignment = .centerX;stack.spacing=16;stack.setCustomSpacing(30,after:subtitle);if mode == .rest{stack.setCustomSpacing(25,after:digits)};stack.setCustomSpacing(28,after:poetry);stack.translatesAutoresizingMaskIntoConstraints=false;view.addSubview(stack)
   NSLayoutConstraint.activate([stack.centerXAnchor.constraint(equalTo:view.centerXAnchor),stack.centerYAnchor.constraint(equalTo:view.centerYAnchor),stack.widthAnchor.constraint(equalTo:view.widthAnchor,multiplier:0.78),button.widthAnchor.constraint(equalToConstant:180),button.heightAnchor.constraint(greaterThanOrEqualToConstant:38)])
   for text in views.compactMap({$0 as? NSTextField}){text.widthAnchor.constraint(lessThanOrEqualTo:stack.widthAnchor).isActive=true}
   windows.append(w);if present{w.orderFrontRegardless()}
  }
  if present{NSApp.activate(ignoringOtherApps:true);windows.first?.makeKeyAndOrderFront(nil)}
 }
 func tick(now:Date=Date()){guard let countdown=countdown else{return};let remaining=countdown.remaining(at:now);countdownLabels.forEach{$0.stringValue=RestCountdown.display(remaining)};if remaining==0{finish()}}
 func stopVideo(){videoPlayers.forEach{$0.pause()};videoLoopers.forEach{$0.disableLooping()};videoPlayers.forEach{$0.removeAllItems()};videoLoopers=[];videoPlayers=[]}
 func dismissForLock(){previousApp=nil;finish()}
 @objc func finish(){guard isActive else{return};stopVideo();timer?.invalidate();timer=nil;countdown=nil;mode=nil;if let keyMonitor=keyMonitor{NSEvent.removeMonitor(keyMonitor);self.keyMonitor=nil};windows.forEach{$0.orderOut(nil);$0.close()};windows=[];countdownLabels=[];image=nil;onFinish();if let app=previousApp,app.processIdentifier != ProcessInfo.processInfo.processIdentifier{app.activate(options:[])};previousApp=nil}
}
