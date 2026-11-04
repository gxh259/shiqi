import Cocoa
import ServiceManagement

extension Delegate {
 var quitMenuTitle:String {let version=Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String ?? "未知版本";return "退出诗栖 · v\(version)"}
 func actionItem(_ title:String,_ command:String,_ key:String="") -> NSMenuItem {
  let item=NSMenuItem(title:title,action:#selector(menuAction(_:)),keyEquivalent:key);item.target=self;item.representedObject=command
  if ["pair","wall","poem"].contains(command){item.keyEquivalentModifierMask=[]};return item
 }
 func settingGroup(_ title:String,_ key:String,_ values:[(String,String)]) -> NSMenuItem {
  let root=NSMenuItem(title:title,action:nil,keyEquivalent:"");let menu=NSMenu(title:title);root.submenu=menu
  for (label,value) in values {let item=NSMenuItem(title:label,action:#selector(changeSetting(_:)),keyEquivalent:"");item.target=self;item.representedObject=["key":key,"value":value];menu.addItem(item)};return root
 }
 func makePreferences() -> NSMenuItem {
  let root=NSMenuItem(title:"休息提醒与偏好设置",action:nil,keyEquivalent:"");let prefs=NSMenu();root.submenu=prefs
  let login=NSMenuItem(title:"登录时启动诗栖",action:#selector(toggleLogin),keyEquivalent:"");login.target=self;login.state=SMAppService.mainApp.status == .enabled ? .on : .off;prefs.addItem(login);loginMenu=login
  let display=NSMenuItem(title:"调整诗歌显示",action:nil,keyEquivalent:"");let options=NSMenu();display.submenu=options
  options.addItem(actionItem("完整显示设置…","display"))
  let font=NSMenuItem(title:"字体…",action:#selector(choosePoetryFont),keyEquivalent:"");font.target=self;options.addItem(font)
  options.addItem(settingGroup("简繁切换","script",[("原文","original"),("简体","simplified"),("繁体","traditional")]))
  options.addItem(settingGroup("布局方向","direction",[("横排","horizontal"),("竖排（从右向左）","vertical")]))
  options.addItem(settingGroup("首行缩进","indent",[0,18,22,27,36,44,54].map{("\($0) 磅","\($0)")}))
  options.addItem(settingGroup("每行高度 / 列距","lineHeight",[22,28,35,42,48,60,80].map{("\($0) 磅","\($0)")}))
  options.addItem(settingGroup("朝代诗人格式","authorFormat",[("[唐] 李白","brackets"),("唐 · 李白","dot"),("李白〔唐〕","after"),("仅诗人姓名","author")]))
  options.addItem(settingGroup("下划线","underline",[("关闭","false"),("开启","true")]))
  options.addItem(settingGroup("下划线类型","underlineStyle",[("单实线","single"),("双实线","double"),("点线","dotted"),("虚线","dashed")]))
  options.addItem(settingGroup("文字倾斜","slant",[("向左","-0.2"),("正常","0"),("向右","0.2"),("更倾斜","0.4")]))
  options.addItem(settingGroup("去掉句号","removePeriod",[("保留","false"),("去掉","true")]))
  options.addItem(settingGroup("去掉逗号、顿号","removeComma",[("保留","false"),("去掉","true")]))
  options.addItem(settingGroup("文字阴影","shadowEnabled",[("关闭","false"),("开启","true")]))
  options.addItem(settingGroup("阴影颜色","shadowColor",[("黑色","#000000"),("墨绿","#527666"),("灰色","#666666")]))
  options.addItem(settingGroup("阴影半径","shadowRadius",[0,2,4,6,8,12,20].map{("\($0)","\($0)")}))
  options.addItem(settingGroup("切换诗配图时，保持当前设置","keepSettings",[("关闭","false"),("开启","true")]))
  options.addItem(settingGroup("切换诗配图时，字体不变","keepFont",[("关闭","false"),("开启","true")]))
  options.addItem(actionItem("恢复默认显示设置","resetDisplay"))
  options.addItem(.separator())
  options.addItem(settingGroup("字号","size",[16,18,20,22,26,30,34,38].map{("\($0)","\($0)")}))
  options.addItem(settingGroup("文字阴影浓度","opacity",[0,20,40,60,72,80,100].map{("\($0)%","\($0)")}))
  let color=settingGroup("字体颜色","color",[("米白","#fff8e8"),("纯白","#ffffff"),("墨黑","#182724"),("暖金","#e7c77d"),("浅绿","#c3dcc5")]);color.submenu?.addItem(.separator());let custom=NSMenuItem(title:"自定义颜色…",action:#selector(chooseColor),keyEquivalent:"");custom.target=self;color.submenu?.addItem(custom);options.addItem(color)
  options.addItem(settingGroup("诗歌显示位置","position",PoemPlacement.options))
  options.addItem(settingGroup("诗词对齐","align",[("默认（诗词左对齐，古文两端对齐）","default"),("左对齐","left"),("居中","center"),("右对齐","right"),("两端对齐","justified")]))
  options.addItem(settingGroup("自动切换诗画","interval",[("关闭","0"),("每分钟","60"),("每 5 分钟","300"),("每 15 分钟","900"),("每 30 分钟","1800")]))
  prefs.addItem(display);let rest=settingGroup("休息提醒","reminder",[("关闭","0"),("每 20 分钟","1200"),("每 30 分钟","1800"),("每小时","3600")]);rest.submenu?.addItem(.separator());rest.submenu?.addItem(settingGroup("休息时长","restDuration",[("20 秒","20"),("1 分钟","60"),("3 分钟","180"),("5 分钟","300"),("10 分钟","600")]));rest.submenu?.addItem(actionItem("现在休息一下","rest"));prefs.addItem(rest)
  prefs.addItem(actionItem("屏幕保护模式","screensaver"));return root
 }
 func populateOperations(_ menu:NSMenu, shell:Bool){
  if shell {let show=NSMenuItem(title:"显示诗栖",action:#selector(show),keyEquivalent:"");show.target=self;menu.addItem(show)}
  for (t,c,k) in [("显示桌面诗画","desktop",""),("隐藏桌面诗画","hideDesktop",""),("切换诗配图","pair","\u{f70a}"),("切换壁纸","wall","\u{f70b}"),("切换诗歌","poem","\u{f70c}"),("设置壁纸到当前桌面","wallpaper",""),("精选诗配图","gallery",""),("自定义诗歌","custom",""),("诗歌赏析","analysis",""),("搜索","search","f")] {menu.addItem(actionItem(t,c,k))}
  let other=NSMenuItem(title:"其他功能",action:nil,keyEquivalent:"");let items=NSMenu();other.submenu=items
  for (t,c,k) in [("收藏当前壁纸","favoriteWall",""),("收藏当前诗歌","favorite","d"),("收藏列表","collection",""),("历史记录","history",""),("复制诗歌文本","copy","c"),("下载诗画截屏","export","s"),("仅保存壁纸","image",""),("分享诗配图","share",""),("动态壁纸","video",""),("停止动态壁纸","stopVideo","")] {if c=="copy"{items.addItem(.separator())};items.addItem(actionItem(t,c,k))}
  items.addItem(.separator());items.addItem(actionItem("版本更新…","update"));menu.addItem(other)
  menu.addItem(makePreferences());menu.addItem(screensMenu())
  if shell {menu.addItem(.separator());menu.addItem(withTitle:quitMenuTitle,action:#selector(NSApplication.terminate(_:)),keyEquivalent:"q")}
 }
 func configureMenus(menu:NSMenu){let root=NSMenuItem(title:"操作",action:nil,keyEquivalent:"");let ops=NSMenu();populateOperations(ops,shell:false);root.submenu=ops;menu.addItem(root);let statusMenu=NSMenu();populateOperations(statusMenu,shell:true);status.menu=statusMenu;syncMenuChecks()}
 @objc func changeSetting(_ item:NSMenuItem){guard let data=item.representedObject as? [String:String],let key=data["key"],let value=data["value"] else{return};applySetting(key,value)}
 func applySetting(_ key:String,_ value:String){let args=String(data:try! JSONSerialization.data(withJSONObject:[key,value]),encoding:.utf8)!;runWeb("applySetting(...\(args))")}
 @objc func chooseColor(){colorSettingKey="color";openStyleColor()}
 func openStyleColor(){restOverlay.finish();let picker=NSColorPanel.shared;picker.setTarget(self);picker.setAction(#selector(colorChanged(_:)));picker.isContinuous=true;picker.showsAlpha=false;picker.color=NSColor.poetryHex(poetryStyle.string(colorSettingKey,colorSettingKey == "color" ? "#fff8e8":"#000000")) ?? desktopColor;picker.makeKeyAndOrderFront(nil);NSApp.activate(ignoringOtherApps:true)}
 @objc func colorChanged(_ panel:NSColorPanel){guard let c=panel.color.usingColorSpace(.sRGB) else{return};applySetting(colorSettingKey,String(format:"#%02x%02x%02x",Int(c.redComponent*255),Int(c.greenComponent*255),Int(c.blueComponent*255)))}
 func syncMenuChecks(){
  let dict=(UserDefaults.standard.string(forKey:"savedState").flatMap{$0.data(using:.utf8)}).flatMap{try? JSONSerialization.jsonObject(with:$0)} as? [String:Any] ?? [:]
  func walk(_ menu:NSMenu?){for item in menu?.items ?? [] {if item.action == #selector(toggleLogin){item.state=SMAppService.mainApp.status == .enabled ? .on : .off};if let data=item.representedObject as? [String:String],let key=data["key"],let value=data["value"],let current=dict[key]{let currentValue=["true","false"].contains(value) ? ((current as? Bool ?? false) ? "true":"false"):String(describing:current).lowercased();item.state=currentValue==value.lowercased() ? .on : .off};walk(item.submenu)}}
  walk(status.menu);walk(NSApp.mainMenu)
 }
 func menuTree(_ menu:NSMenu) -> [[String:Any]] {menu.items.filter{!$0.isSeparatorItem}.map{["title":$0.title,"children":$0.submenu.map{menuTree($0)} ?? []]}}
}
