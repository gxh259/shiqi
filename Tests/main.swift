import Foundation
var checks:[String]=[]
func check(_ title:String,_ value:Bool){guard value else{fatalError(title)};checks.append(title)}
check("数字版本比较",ReleaseVersion("1.9.0")! < ReleaseVersion("1.10.0")!)
check("相等版本不更新",ReleaseVersion("v1.3.0")==ReleaseVersion("1.3"))
check("拒绝预发行版本",ReleaseVersion("v1.4.0-beta")==nil)
check("拒绝恶意版本号",ReleaseVersion("../../../1.4")==nil)
check("拒绝 HTTP",!ReleaseDownload.allowedResponse(URL(string:"http://github.com/test")!))
check("允许 GitHub 下载重定向",ReleaseDownload.allowedResponse(URL(string:"https://release-assets.githubusercontent.com/test")!))
check("拒绝伪造域名",!ReleaseDownload.allowedResponse(URL(string:"https://githubusercontent.com.evil.example/a")!))
let asset:[String:Any] = ["name":"ShiQi-1.3.0-universal.dmg","state":"uploaded","browser_download_url":"https://github.com/gxh259/shiqi/releases/download/v1.3.0/ShiQi-1.3.0-universal.dmg","digest":"sha256:"+String(repeating:"a",count:64)]
func metadata(_ changed:[String:Any]=[:],_ changedAsset:[String:Any]=[:]) -> Data {var a=asset;for (k,v) in changedAsset{a[k]=v};var r:[String:Any]=["draft":false,"prerelease":false,"tag_name":"v1.3.0","assets":[a]];for(k,v) in changed{r[k]=v};return try! JSONSerialization.data(withJSONObject:r)}
check("正式版本元数据",(try? ReleaseDownload.parse(metadata()).version)=="1.3.0")
check("拒绝其他仓库",(try? ReleaseDownload.parse(metadata([:],["browser_download_url":"https://github.com/attacker/app/releases/download/v1.3.0/ShiQi-1.3.0-universal.dmg"])))==nil)
check("拒绝缺失校验值",(try? ReleaseDownload.parse(metadata([:],["digest":""])))==nil)
check("拒绝草稿",(try? ReleaseDownload.parse(metadata(["draft":true])))==nil)
check("拒绝预发行包",(try? ReleaseDownload.parse(metadata(["prerelease":true])))==nil)
let file=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString);try Data("abc".utf8).write(to:file);defer{try? FileManager.default.removeItem(at:file)}
check("SHA-256 文件校验",try ReleaseDownload.fileHash(file)=="ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
print(String(data:try! JSONSerialization.data(withJSONObject:["success":true,"checks":checks],options:.prettyPrinted),encoding:.utf8)!)
