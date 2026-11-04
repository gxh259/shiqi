import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
let out=CommandLine.arguments[1];try! FileManager.default.createDirectory(atPath:out,withIntermediateDirectories:true)
for i in 1...3 {
 let w=2560,h=1600;let c=CGContext(data:nil,width:w,height:h,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
 let colors:[CGColor]=[CGColor(red:0.08+Double(i)*0.02,green:0.2+Double(i)*0.03,blue:0.23+Double(i)*0.04,alpha:1),CGColor(red:0.45,green:0.6,blue:0.59,alpha:1)];let g=CGGradient(colorsSpace:CGColorSpaceCreateDeviceRGB(),colors:colors as CFArray,locations:[0,1])!;c.drawLinearGradient(g,start:CGPoint(x:0,y:0),end:CGPoint(x:0,y:h),options:[])
 c.setFillColor(CGColor(red:0.97,green:0.92,blue:0.75,alpha:0.85));c.fillEllipse(in:CGRect(x:540+120*i,y:1100,width:140,height:140))
 for layer in 0...3 {c.setFillColor(CGColor(red:0.1,green:0.25,blue:0.27,alpha:0.3+Double(layer)*0.15));c.beginPath();c.move(to:.zero);for x in stride(from:0,through:w,by:20){let y=Double(500-layer*110)+sin(Double(x)/400+Double(i+layer))*160+sin(Double(x)/170+Double(layer))*45;c.addLine(to:CGPoint(x:Double(x),y:y))};c.addLine(to:CGPoint(x:w,y:0));c.closePath();c.fillPath()}
 let url=URL(fileURLWithPath:out+"/mountain-\(i).png");let d=CGImageDestinationCreateWithURL(url as CFURL,UTType.png.identifier as CFString,1,nil)!;CGImageDestinationAddImage(d,c.makeImage()!,nil);CGImageDestinationFinalize(d)
}
