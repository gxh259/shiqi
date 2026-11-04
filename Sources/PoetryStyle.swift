import Cocoa
import CoreText
struct PoetryStyle {
 var values:[String:Any]=[:]
 func string(_ key:String,_ fallback:String)->String{values[key] as? String ?? fallback}
 func number(_ key:String,_ fallback:Double)->CGFloat{CGFloat((values[key] as? NSNumber)?.doubleValue ?? fallback)}
 func flag(_ key:String,_ fallback:Bool)->Bool{values[key] as? Bool ?? fallback}
 var font:NSFont{NSFont(name:string("fontName","Songti SC"),size:number("size",22)) ?? .systemFont(ofSize:number("size",22))}
 func text(title:String,author:String,body:String,category:String)->String{
  let dynasty=category.hasPrefix("唐") ? "唐":category.hasPrefix("宋") ? "宋":category.hasPrefix("元") ? "元":""
  let mode=string("authorFormat","brackets")
  let byline=mode == "author" || dynasty.isEmpty ? author : mode == "dot" ? dynasty+" · "+author : mode == "after" ? author+"〔"+dynasty+"〕":"["+dynasty+"] "+author
  var verse=body
  if flag("removePeriod",false){verse=verse.replacingOccurrences(of:"。",with:"").replacingOccurrences(of:"．",with:"")}
  if flag("removeComma",false){verse=verse.replacingOccurrences(of:"，",with:"").replacingOccurrences(of:"、",with:"")}
  let raw=title+"\n"+byline+"\n\n"+verse
  switch string("script","original"){
  case "simplified":return raw.applyingTransform(StringTransform("Traditional-Simplified"),reverse:false) ?? raw
  case "traditional":return raw.applyingTransform(StringTransform("Simplified-Traditional"),reverse:false) ?? raw
  default:return raw
  }
 }
 func attributes(scale:CGFloat,category:String)->[NSAttributedString.Key:Any]{
  let size=number("size",22)*scale;let base=NSFont(name:string("fontName","Songti SC"),size:size) ?? .systemFont(ofSize:size)
  var matrix=CGAffineTransform(a:1,b:0,c:number("slant",0),d:1,tx:0,ty:0)
  let ct=CTFontCreateWithName(base.fontName as CFString,size,&matrix)
  let paragraph=NSMutableParagraphStyle();let align=string("align","left")
  paragraph.alignment=align == "center" ? .center:align == "right" ? .right:align == "justified" || (align == "default" && category.contains("古文")) ? .justified:.left
  paragraph.firstLineHeadIndent=number("indent",0)*scale
  let height=max(size,number("lineHeight",35)*scale);paragraph.minimumLineHeight=height;paragraph.maximumLineHeight=height
  var result:[NSAttributedString.Key:Any]=[.font:ct,.foregroundColor:NSColor.poetryHex(string("color","#fff8e8")) ?? NSColor.white,.paragraphStyle:paragraph,.verticalGlyphForm:string("direction","horizontal")=="vertical"]
  if flag("underline",false){let style=string("underlineStyle","single");result[.underlineStyle]=style == "double" ? NSUnderlineStyle.double.rawValue:style == "dotted" ? NSUnderlineStyle.single.rawValue|NSUnderlineStyle.patternDot.rawValue:style == "dashed" ? NSUnderlineStyle.single.rawValue|NSUnderlineStyle.patternDash.rawValue:NSUnderlineStyle.single.rawValue}
  return result
 }
 func textImage(size:NSSize,title:String,author:String,body:String,category:String,scale:CGFloat=1)->NSImage{
  let result=NSImage(size:size);result.lockFocus();defer{result.unlockFocus()}
  guard let ctx=NSGraphicsContext.current?.cgContext else{return result}
  let text=text(title:title,author:author,body:body,category:category)
  let attributed=NSAttributedString(string:text,attributes:attributes(scale:scale,category:category))
  let vertical=string("direction","horizontal")=="vertical"
  let width=size.width*0.37;let maxHeight=size.height*0.78
  let framesetter=CTFramesetterCreateWithAttributedString(attributed)
  let measured=CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRange(),nil,CGSize(width:width,height:100000),nil)
  let boxSize=CGSize(width:width,height:vertical ? maxHeight:min(maxHeight,ceil(measured.height)+number("lineHeight",35)*scale))
  let parts=PoemPlacement.normalized(string("position","middle-right")).split(separator:"-")
  let x=parts[1]=="left" ? size.width*0.06:parts[1]=="center" ? (size.width-boxSize.width)/2:size.width*0.94-boxSize.width
  let y=parts[0]=="top" ? size.height*0.91-boxSize.height:parts[0]=="bottom" ? size.height*0.09:(size.height-boxSize.height)/2
  ctx.saveGState();defer{ctx.restoreGState()};ctx.clip(to:CGRect(x:x-12*scale,y:y-12*scale,width:boxSize.width+24*scale,height:boxSize.height+24*scale))
  if flag("shadowEnabled",true){let color=(NSColor.poetryHex(string("shadowColor","#000000")) ?? .black).withAlphaComponent(number("opacity",72)/100);ctx.setShadow(offset:CGSize(width:0,height:-2*scale),blur:number("shadowRadius",6)*scale,color:color.cgColor)}
  let path=CGPath(rect:CGRect(x:x,y:y,width:boxSize.width,height:boxSize.height),transform:nil)
  let attrs=vertical ? [kCTFrameProgressionAttributeName:CTFrameProgression.rightToLeft.rawValue] as CFDictionary:nil
  let frame=CTFramesetterCreateFrame(framesetter,CFRange(),path,attrs);ctx.textMatrix = .identity;CTFrameDraw(frame,ctx)
  return result
 }
}
