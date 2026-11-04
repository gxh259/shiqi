import Cocoa
final class UpdateRedirects:NSObject,URLSessionTaskDelegate {
 func urlSession(_ session:URLSession,task:URLSessionTask,willPerformHTTPRedirection response:HTTPURLResponse,newRequest request:URLRequest,completionHandler:@escaping (URLRequest?)->Void){completionHandler(request.url.map{ReleaseDownload.allowedResponse($0)} == true ? request:nil)}
}
final class UpdateController:NSObject,NSWindowDelegate {
 weak var owner:Delegate?;var busy=false;var cancelled=false;private let redirects=UpdateRedirects();var progress:NSPanel?;var progressLabel:NSTextField?;var activeSession:URLSession?
 init(owner:Delegate){self.owner=owner;super.init()}
 @MainActor func setProgress(_ message:String){if progress==nil{let panel=NSPanel(contentRect:NSRect(x:0,y:0,width:430,height:125),styleMask:[.titled,.closable],backing:.buffered,defer:false);panel.title="诗栖版本更新";panel.isReleasedWhenClosed=false;panel.delegate=self;let text=NSTextField(wrappingLabelWithString:message);text.frame=NSRect(x:65,y:34,width:340,height:55);panel.contentView?.addSubview(text);progressLabel=text;let spin=NSProgressIndicator(frame:NSRect(x:22,y:49,width:26,height:26));spin.style = .spinning;spin.startAnimation(nil);panel.contentView?.addSubview(spin);panel.center();progress=panel};progressLabel?.stringValue=message;progress?.makeKeyAndOrderFront(nil);NSApp.activate(ignoringOtherApps:true)}
 func windowWillClose(_ notification:Notification){cancelled=true;activeSession?.invalidateAndCancel()}
 @MainActor func alert(_ title:String,_ message:String){progress?.orderOut(nil);let box=NSAlert();box.messageText=title;box.informativeText=message;NSApp.activate(ignoringOtherApps:true);box.runModal()}
 func checkForUpdates(){Task{@MainActor in
  guard !busy else{alert("正在更新","请等待当前版本检查或下载完成。");return};busy=true;cancelled=false;setProgress("正在检查 GitHub 最新版本…");defer{busy=false;progress?.orderOut(nil);activeSession=nil}
  let current=Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String ?? "0.0";let config=URLSessionConfiguration.default;config.timeoutIntervalForRequest=45;config.timeoutIntervalForResource=600;config.requestCachePolicy = .reloadIgnoringLocalCacheData
  let session=URLSession(configuration:config,delegate:redirects,delegateQueue:nil);activeSession=session;defer{session.invalidateAndCancel()}
  owner?.reply("正在检查 GitHub 最新版本…")
  var working:URL?;var staged:URL?;var handedOff=false
  defer{if !handedOff {if let staged=staged{try? FileManager.default.removeItem(at:staged)};if let working=working{try? FileManager.default.removeItem(at:working)}}}
  do {
   var request=URLRequest(url:URL(string:"https://api.github.com/repos/gxh259/shiqi/releases/latest")!);request.setValue("ShiQi/\(current)",forHTTPHeaderField:"User-Agent");request.setValue("application/vnd.github+json",forHTTPHeaderField:"Accept")
   let (data,response)=try await session.data(for:request);guard let http=response as? HTTPURLResponse,http.statusCode==200,let responseURL=http.url,ReleaseDownload.allowedResponse(responseURL) else{throw UpdateFailure(message:"无法读取 GitHub 最新版本，请稍后重试。")}
   guard !cancelled else{throw URLError(.cancelled)};let release=try ReleaseDownload.parse(data);guard let latest=ReleaseVersion(release.version),let installed=ReleaseVersion(current) else{throw UpdateFailure(message:"当前版本号无效，无法安全比较。")}
   guard installed<latest else{alert("已是最新版本","当前版本 \(current)，GitHub 最新版本 \(release.version)。");return}
   let fm=FileManager.default;let dir=fm.temporaryDirectory.appendingPathComponent("ShiQi-update-"+UUID().uuidString,isDirectory:true);try fm.createDirectory(at:dir,withIntermediateDirectories:true);working=dir
   setProgress("正在下载更新，可关闭此窗口取消…");let (temporary,downloadResponse)=try await session.download(from:release.url)
   guard let downloaded=downloadResponse as? HTTPURLResponse,downloaded.statusCode==200,let finalURL=downloaded.url,ReleaseDownload.allowedResponse(finalURL) else{throw UpdateFailure(message:"更新包下载失败或来源不可信。")}
   let dmg=dir.appendingPathComponent("update.dmg");try fm.moveItem(at:temporary,to:dmg)
   setProgress("正在校验下载包…");let digest=try await Task.detached{try ReleaseDownload.fileHash(dmg)}.value;guard digest==release.sha256 else{throw UpdateFailure(message:"下载包 SHA-256 不匹配，原应用未改动。")}
   guard !cancelled else{throw URLError(.cancelled)};let mount=dir.appendingPathComponent("mounted",isDirectory:true)
   try await run("/usr/bin/hdiutil",["attach","-readonly","-nobrowse","-mountpoint",mount.path,dmg.path])
   do {
    let candidate=mount.appendingPathComponent("诗栖.app",isDirectory:true);try validate(candidate,version:release.version);try await run("/usr/bin/codesign",["--verify","--deep","--strict",candidate.path])
    try owner?.preservePrivateResources();setProgress("正在准备安装，完成后将自动重启…");let target=Bundle.main.bundleURL;let parent=target.deletingLastPathComponent();guard fm.isWritableFile(atPath:parent.path) else{try await run("/usr/bin/hdiutil",["detach",mount.path]);let downloads=fm.urls(for:.downloadsDirectory,in:.userDomainMask)[0].appendingPathComponent("ShiQi-\(release.version)-universal.dmg");let safe=fm.fileExists(atPath:downloads.path) ? downloads.deletingLastPathComponent().appendingPathComponent("ShiQi-\(release.version)-\(UUID().uuidString).dmg"):downloads;try fm.copyItem(at:dmg,to:safe);NSWorkspace.shared.open(safe);alert("需要手动完成安装","当前应用目录不可写，已打开经过校验的安装包。请退出诗栖后将应用拖入 Applications；原应用尚未替换。");return}
    let stage=parent.appendingPathComponent(".ShiQi-update-"+UUID().uuidString+".app",isDirectory:true);staged=stage;try fm.copyItem(at:candidate,to:stage);try await run("/usr/bin/codesign",["--verify","--deep","--strict",stage.path])
    try await run("/usr/bin/hdiutil",["detach",mount.path])
    guard !cancelled else{throw URLError(.cancelled)};let helperSource=Bundle.main.executableURL!.deletingLastPathComponent().appendingPathComponent("ShiQiUpdater");let helper=dir.appendingPathComponent("ShiQiUpdater");try fm.copyItem(at:helperSource,to:helper)
    let process=Process();process.executableURL=helper;process.arguments=[String(ProcessInfo.processInfo.processIdentifier),target.path,stage.path,release.version,dir.path];try process.run();handedOff=true;NSApp.terminate(nil)
   }catch{try? await run("/usr/bin/hdiutil",["detach",mount.path]);throw error}
  }catch{alert("更新未完成",error.localizedDescription+"\n原应用与个人素材保留，可稍后重试。")}
 }}
 func validate(_ url:URL,version:String)throws{guard let bundle=Bundle(url:url),bundle.bundleIdentifier=="local.gxh.shiqi",bundle.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String==version,let exe=bundle.executableURL,FileManager.default.isExecutableFile(atPath:exe.path) else{throw UpdateFailure(message:"安装包中的应用标识或版本不正确。")}}
 func run(_ executable:String,_ args:[String])async throws {try await Task.detached{let p=Process();p.executableURL=URL(fileURLWithPath:executable);p.arguments=args;p.standardOutput=FileHandle.nullDevice;p.standardError=FileHandle.nullDevice;try p.run();p.waitUntilExit();guard p.terminationStatus==0 else{throw UpdateFailure(message:"更新步骤失败：\(URL(fileURLWithPath:executable).lastPathComponent)，错误码 \(p.terminationStatus)。")}}.value}
}
