import Cocoa
import Darwin
let application=NSApplication.shared;application.setActivationPolicy(.accessory)
let args=CommandLine.arguments
func fail(_ text:String)->Never{let alert=NSAlert();alert.messageText="诗栖更新未完成";alert.informativeText=text;NSApp.activate(ignoringOtherApps:true);alert.runModal();exit(1)}
guard args.count==6,let pid=Int32(args[1]) else{exit(2)}
let target=URL(fileURLWithPath:args[2]).standardizedFileURL;let stage=URL(fileURLWithPath:args[3]).standardizedFileURL;let version=args[4];let working=URL(fileURLWithPath:args[5]).standardizedFileURL
let fm=FileManager.default
guard target.pathExtension=="app",stage.pathExtension=="app",stage.lastPathComponent.hasPrefix(".ShiQi-update-"),stage.deletingLastPathComponent()==target.deletingLastPathComponent(),working.lastPathComponent.hasPrefix("ShiQi-update-"),let bundle=Bundle(url:stage),bundle.bundleIdentifier=="local.gxh.shiqi",bundle.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String==version else{fail("更新参数或新应用标识无效，未替换应用。")}
let verify=Process();verify.executableURL=URL(fileURLWithPath:"/usr/bin/codesign");verify.arguments=["--verify","--deep","--strict",stage.path];do{try verify.run();verify.waitUntilExit()}catch{fail(error.localizedDescription)};guard verify.terminationStatus==0 else{fail("新应用签名结构校验失败，未替换应用。")}
for _ in 0..<120{if kill(pid,0) != 0{break};Thread.sleep(forTimeInterval:0.25)}
guard kill(pid,0) != 0 else{fail("旧应用尚未退出，原版本保留。请退出后重试。")}
let backup=target.deletingLastPathComponent().appendingPathComponent(".ShiQi-backup-"+UUID().uuidString+".app",isDirectory:true)
var backedUp=false;var installed=false
do {
 try fm.moveItem(at:target,to:backup);backedUp=true
 try fm.moveItem(at:stage,to:target);installed=true
 var result:Result<NSRunningApplication,Error>?
 let options=NSWorkspace.OpenConfiguration();options.createsNewApplicationInstance=true;if ProcessInfo.processInfo.environment["SHIQI_UPDATE_SELF_TEST"]=="1"{options.arguments=["--self-test"]}
 NSWorkspace.shared.openApplication(at:target,configuration:options){app,error in if let error=error{result = .failure(error)}else if let app=app{result = .success(app)}else{result = .failure(NSError(domain:"ShiQiUpdate",code:1))}}
 let deadline=Date().addingTimeInterval(20);while result==nil && Date()<deadline{RunLoop.current.run(until:Date().addingTimeInterval(0.1))}
 guard let launch=result else{throw NSError(domain:"ShiQiUpdate",code:2,userInfo:[NSLocalizedDescriptionKey:"新版本启动超时。"])}
 if case .failure(let error)=launch{throw error}
 let report:[String:Any] = ["success":true,"version":version,"target":target.path,"backup":backup.path,"date":ISO8601DateFormatter().string(from:Date())];let log=fm.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("ShiQi",isDirectory:true);try? fm.createDirectory(at:log,withIntermediateDirectories:true);try? JSONSerialization.data(withJSONObject:report,options:.prettyPrinted).write(to:log.appendingPathComponent("last-update.json"))
 // Keep the previous application beside the installed one for manual recovery.
 try? fm.removeItem(at:working)
 exit(0)
}catch{
 if installed{try? fm.moveItem(at:target,to:stage)}
 if backedUp{try? fm.moveItem(at:backup,to:target)}
 NSWorkspace.shared.open(target)
 fail("安装或启动失败，已尝试恢复旧版本。\n"+error.localizedDescription)
}
