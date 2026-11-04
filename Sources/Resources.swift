import Cocoa
import WebKit
extension Delegate {
 static var support:URL {FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("ShiQi",isDirectory:true)}
 var resourceRoot:URL {let custom=Self.support.appendingPathComponent("PrivateResources",isDirectory:true);if FileManager.default.fileExists(atPath:custom.appendingPathComponent("library.json").path),FileManager.default.fileExists(atPath:custom.appendingPathComponent("wallpapers.json").path),FileManager.default.fileExists(atPath:custom.appendingPathComponent("Wallpapers").path){return custom};return Bundle.main.resourceURL!}
 func configureWebData(_ config:WKWebViewConfiguration){
  if isValidationRun{config.websiteDataStore = .nonPersistent()}
  do{let library=try Data(contentsOf:resourceRoot.appendingPathComponent("library.json"));let walls=try Data(contentsOf:resourceRoot.appendingPathComponent("wallpapers.json"));let poems=try JSONSerialization.jsonObject(with:library);let names=try JSONSerialization.jsonObject(with:walls);guard let list=poems as? [[String:Any]],!list.isEmpty,let images=names as? [String],!images.isEmpty else {return}
   let saved=String(data:try JSONSerialization.data(withJSONObject:[isValidationRun ? "{}" : (UserDefaults.standard.string(forKey:"savedState") ?? "{}")]),encoding:.utf8)!
   let js="const LIBRARY=\(String(data:library,encoding:.utf8)!);const WALLPAPERS=\(String(data:walls,encoding:.utf8)!);window.SHIQI_STATE=\(saved)[0];"
   config.userContentController.addUserScript(WKUserScript(source:js,injectionTime:.atDocumentStart,forMainFrameOnly:true))
  }catch{NSLog("Failed to load poetry resources: %@",error.localizedDescription)}
 }
 func preservePrivateResources() throws {
  let fm=FileManager.default;let destination=Self.support.appendingPathComponent("PrivateResources",isDirectory:true)
  guard resourceRoot.standardizedFileURL != destination.standardizedFileURL else{return}
  let root=resourceRoot;let library=try Data(contentsOf:root.appendingPathComponent("library.json"));let list=(try JSONSerialization.jsonObject(with:library)) as? [Any] ?? []
  // Public sample resources are replaced by the next public release; user resources persist separately.
  let edition=Bundle.main.object(forInfoDictionaryKey:"ShiQiResourceEdition") as? String;guard edition=="personal" || (edition==nil && list.count>3) else{return}
  try fm.createDirectory(at:Self.support,withIntermediateDirectories:true);let staged=Self.support.appendingPathComponent(".PrivateResources-"+UUID().uuidString,isDirectory:true);try fm.createDirectory(at:staged,withIntermediateDirectories:true)
  do {for name in ["library.json","wallpapers.json","Wallpapers"] {try fm.copyItem(at:root.appendingPathComponent(name),to:staged.appendingPathComponent(name))};try fm.moveItem(at:staged,to:destination)}catch{try? fm.removeItem(at:staged);throw error}
 }
}
extension NSColor {
 static func poetryHex(_ value:String)->NSColor? {guard value.range(of:"^#[0-9a-fA-F]{6}$",options:.regularExpression) != nil,let raw=UInt32(value.dropFirst(),radix:16) else{return nil};return NSColor(srgbRed:CGFloat((raw>>16)&255)/255,green:CGFloat((raw>>8)&255)/255,blue:CGFloat(raw&255)/255,alpha:1)}
}
