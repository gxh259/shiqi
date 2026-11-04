import Foundation
import CryptoKit
struct ReleaseVersion:Comparable,Equatable {
 let numbers:[Int]
 init?(_ raw:String){let value=raw.hasPrefix("v") ? String(raw.dropFirst()) : raw;guard value.range(of:"^[0-9]+(\\.[0-9]+){1,3}$",options:.regularExpression) != nil else{return nil};let pieces=value.split(separator:".").compactMap{Int($0)};guard pieces.count==value.split(separator:".").count else{return nil};numbers=pieces}
 static func <(a:Self,b:Self)->Bool {for i in 0..<max(a.numbers.count,b.numbers.count){let x=i<a.numbers.count ? a.numbers[i]:0;let y=i<b.numbers.count ? b.numbers[i]:0;if x != y{return x<y}};return false}
 static func ==(a:Self,b:Self)->Bool{!(a<b) && !(b<a)}
}
struct UpdateFailure:LocalizedError {let message:String;var errorDescription:String?{message}}
struct ReleaseDownload {
 let version:String;let url:URL;let sha256:String
 static func parse(_ data:Data)throws->Self {
  guard let json=try JSONSerialization.jsonObject(with:data) as? [String:Any],json["draft"] as? Bool == false,json["prerelease"] as? Bool == false,let tag=json["tag_name"] as? String,ReleaseVersion(tag) != nil,let assets=json["assets"] as? [[String:Any]] else{throw UpdateFailure(message:"GitHub 最新版本信息无效或不是正式版本。")}
  let version=tag.hasPrefix("v") ? String(tag.dropFirst()):tag;let filename="ShiQi-\(version)-universal.dmg"
  guard let asset=assets.first(where:{$0["name"] as? String==filename}),asset["state"] as? String == "uploaded",let raw=asset["browser_download_url"] as? String,let url=URL(string:raw),url.scheme=="https",url.host=="github.com",url.path=="/gxh259/shiqi/releases/download/\(tag)/\(filename)",let digest=asset["digest"] as? String,digest.range(of:"^sha256:[0-9a-fA-F]{64}$",options:.regularExpression) != nil else{throw UpdateFailure(message:"该版本缺少可信的通用 DMG 或 SHA-256 校验值，已停止更新。")}
  return Self(version:version,url:url,sha256:String(digest.dropFirst(7)).lowercased())
 }
 static func allowedResponse(_ url:URL)->Bool {guard url.scheme=="https",let host=url.host?.lowercased() else{return false};return host=="api.github.com" || host=="github.com" || host.hasSuffix(".githubusercontent.com")}
 static func fileHash(_ url:URL)throws->String{let stream=try FileHandle(forReadingFrom:url);defer{try? stream.close()};var hash=SHA256();while let part=try stream.read(upToCount:1024*1024),!part.isEmpty{hash.update(data:part)};return hash.finalize().map{String(format:"%02x",$0)}.joined()}
}
