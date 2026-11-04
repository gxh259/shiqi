import Cocoa
@main struct TypographyTests {
 static func main()throws{
  _=NSApplication.shared
  let title="静夜思 Night",author="李白",body="床前明月光，疑是地上霜。\n举头望明月，低头思故乡。",category="唐诗"
  var style=PoetryStyle()
  assert(style.text(title:title,author:author,body:body,category:category).contains("[唐] 李白"))
  style.values=["script":"traditional","removePeriod":true,"removeComma":true,"authorFormat":"after"]
  let converted=style.text(title:title,author:author,body:body,category:category)
  assert(converted.contains("靜夜思") && converted.contains("舉頭") && !converted.contains("，") && !converted.contains("。") && converted.contains("李白〔唐〕"))
  style.values=["script":"simplified"];assert(style.text(title:"靜夜思",author:author,body:"舉頭望明月",category:category).contains("举头"))
  style.values=[:]
  func pixels(_ style:PoetryStyle)throws->Data {let image=style.textImage(size:NSSize(width:1000,height:700),title:title,author:author,body:body,category:category);return image.tiffRepresentation!}
  let original=try pixels(style);let repeated=try pixels(style);assert(original==repeated,"Rendering must be deterministic")
  let variants:[[String:Any]]=[["direction":"vertical"],["fontName":"Helvetica-Bold"],["size":32],["color":"#ffff00"],["align":"right"],["indent":27],["lineHeight":60],["authorFormat":"dot"],["underline":true],["underline":true,"underlineStyle":"double"],["underline":true,"underlineStyle":"dotted"],["underline":true,"underlineStyle":"dashed"],["slant":0.3],["shadowEnabled":false],["shadowColor":"#527666"],["opacity":20],["shadowRadius":12],["removeComma":true],["position":"bottom-left"]]
  for variant in variants{style.values=variant;let rendered=try pixels(style);assert(rendered != original,"No rendering effect: \(variant)")}
  var underlineImages=Set<Data>();for kind in ["single","double","dotted","dashed"]{style.values=["underline":true,"underlineStyle":kind];underlineImages.insert(try pixels(style))};assert(underlineImages.count==4,"Underline patterns must differ")
  style.values=["direction":"vertical","color":"#f3df94","fontName":"Songti SC","lineHeight":42,"underline":true,"slant":0.1,"position":"middle-center"]
  let changedBody=style.textImage(size:NSSize(width:1000,height:700),title:title,author:author,body:body.replacingOccurrences(of:"明",with:"暗"),category:category).tiffRepresentation!
  let vertical=try pixels(style);assert(vertical != changedBody,"Vertical body must be visible")
  if CommandLine.arguments.count>1 {try style.textImage(size:NSSize(width:1000,height:700),title:title,author:author,body:body,category:category).tiffRepresentation!.write(to:URL(fileURLWithPath:CommandLine.arguments[1]))}
  print("Typography: script conversion, punctuation, author formats and 19 rendered variants passed")
 }
}
