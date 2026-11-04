import Cocoa
@main struct PlacementTests {
 static func main(){
  for size in [NSSize(width:1440,height:900),NSSize(width:1920,height:1080),NSSize(width:900,height:1440)]{
   for text in ["静夜思\n李白\n床前明月光",String(repeating:"长诗文测试\n",count:300)]{
    var frames:[CGRect]=[]
    for (_,position) in PoemPlacement.options{
     let frame=PoemPlacement.frame(in:size,position:position,text:text,fontSize:30)
     assert(CGRect(origin:.zero,size:size).contains(frame));frames.append(frame)
    }
    assert(Set(frames.map{NSStringFromRect($0)}).count==9)
    assert(frames[0].minX<frames[1].minX && frames[1].minX<frames[2].minX)
    assert(frames[0].minY>frames[3].minY && frames[3].minY>frames[6].minY)
   }
  }
  assert(PoemPlacement.normalized("invalid")=="middle-right")
  print("Poem positions: nine placements, landscape/portrait, short/long text, bounds and fallback passed")
 }
}
