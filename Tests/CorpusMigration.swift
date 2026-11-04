import Foundation
import JavaScriptCore
let html=try String(contentsOfFile:CommandLine.arguments[1],encoding:.utf8)
let start=html.range(of:"function migratePublicCorpus(){")!.lowerBound
let end=html.range(of:"migratePublicCorpus();let poems=")!.lowerBound
let fn=String(html[start..<end]);let context=JSContext()!
let old="{p:0,favorites:[0,1,2],history:[{p:2}],custom:[]}"
context.evaluateScript("let state=\(old);let window={SHIQI_PUBLIC_CORPUS:true};\(fn)migratePublicCorpus();")
let data=context.evaluateScript("JSON.stringify(state)")!.toString()!.data(using:.utf8)!
let state=try JSONSerialization.jsonObject(with:data) as! [String:Any]
assert(state["p"] as? Int==119);assert(state["custom"] as? [[String:Any]] != nil)
assert(context.evaluateScript("state.favorites[0]===119&&state.favorites[1]===252&&state.favorites[2]==='legacy-sample-2'&&state.custom.length===1&&state.history[0].p==='legacy-sample-2'")!.toBool())
assert(context.evaluateScript("migratePublicCorpus();state.custom.length===1&&state.p===119")!.toBool())
assert(context.evaluateScript("state=\(old);window.SHIQI_PUBLIC_CORPUS=false;migratePublicCorpus();state.p===0&&state.custom.length===0")!.toBool())
print("migration tests passed")
