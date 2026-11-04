import Cocoa
// Shared by static and video desktops; coordinates use the bottom-left origin.
enum PoemPlacement {
 static let options:[(String,String)]=[("左上","top-left"),("顶部居中","top-center"),("右上","top-right"),("左侧居中","middle-left"),("屏幕中央","middle-center"),("右侧居中","middle-right"),("左下","bottom-left"),("底部居中","bottom-center"),("右下","bottom-right")]
 static func normalized(_ value:String)->String{options.contains{$0.1==value} ? value:"middle-right"}
 static func frame(in size:NSSize,position:String,text:String,fontSize:CGFloat)->CGRect{
  let parts=normalized(position).split(separator:"-");let width=size.width*0.37
  let font=NSFont(name:"Songti SC",size:fontSize) ?? NSFont.systemFont(ofSize:fontSize)
  let measured=(text as NSString).boundingRect(with:NSSize(width:width,height:100000),options:[.usesLineFragmentOrigin,.usesFontLeading],attributes:[.font:font]).height
  let height=min(size.height*0.78,max(fontSize*2,ceil(measured)+fontSize))
  let x=parts[1]=="left" ? size.width*0.06 : parts[1]=="center" ? (size.width-width)/2 : size.width*0.57
  let y=parts[0]=="top" ? size.height*0.91-height : parts[0]=="bottom" ? size.height*0.09 : (size.height-height)/2
  return CGRect(x:x,y:y,width:width,height:height)
 }
}
