# 诗栖 ShiQi

macOS 桌面诗词壁纸应用。诗词直接融入壁纸，无独立黑框、窗口边框或桌面按钮。桌面层位于桌面图标下方，鼠标操作可穿透；菜单栏提供切换、收藏、搜索、赏析、自定义诗词和显示设置。

支持 macOS 13+，Intel 与 Apple Silicon 共用 Universal 2 安装包。

## 安装

下载 [Release](https://github.com/gxh259/shiqi/releases/latest) 中的 DMG，将「诗栖.app」拖到 Applications。或：

```sh
brew tap gxh259/shiqi https://github.com/gxh259/shiqi.git
brew install --cask gxh259/shiqi/shiqi
```

签名说明、可选 `xattr` 命令、更新及卸载见 [安装说明](INSTALL.md)。当前为 ad-hoc 签名，尚未取得 Developer ID 签名或 Apple 公证。

## 功能

- 菜单栏切换诗配图、单独切换壁纸或诗词，桌面同步更新。
- 本地搜索、诗词及壁纸收藏、最近 200 条历史、自定义诗词与赏析。
- 字号、对齐、文字阴影、定时切换和休息提醒。
- 导出诗画 PNG、保存原图、系统分享、设置持久静态桌面。
- 静音视频动态壁纸、应用内全屏屏保、屏幕选择、登录时启动。

定时切换随应用运行而执行。退出后桌面展示移除并露出原有系统壁纸；如需退出后保留诗画，请使用「设置壁纸到当前桌面」。屏保为应用内展示，不是系统 `.saver` 插件。长篇诗词导出超出画布时会标注省略。

## 素材范围

公开发行版包含 3 首公版古诗及 3 张由本仓库程序生成的示例壁纸，不包含现代书籍赏析、第三方壁纸、用户收藏或本机个人文件。自定义诗词与设置仅保存在本机。

构建时可接入自己的资源目录。不要把无公开分发授权的素材提交到仓库或 Release。

## 从源码构建

需要 macOS、Apple Command Line Tools（`xcode-select --install`）及 Python 3；无第三方 Python/Swift 依赖。

```sh
python3 scripts/build.py --output build
python3 scripts/package_dmg.py build/诗栖.app build/ShiQi-1.2.0-universal.dmg
```

构建脚本分别编译 `arm64-apple-macosx13.0` 和 `x86_64-apple-macosx13.0`，通过 `lipo` 合并，最后临时签名并检查双架构。

导入自有 EPUB 和图片，生成仅供本机使用的资源目录：

```sh
python3 scripts/import_resources.py '/path/to/book.epub' '/path/to/wallpapers' private-resources
python3 scripts/build.py --resources private-resources --output build-personal
```

导入器针对本项目所用 EPUB 的段落样式；不是通用电子书解析器，当前提取唐诗、宋词、元曲及对应赏析，不含古文。输出与第三方素材默认在 `.gitignore` 中排除。

重新生成示例壁纸：

```sh
swiftc scripts/wallpaper.swift -o /tmp/shiqi-wallpaper
/tmp/shiqi-wallpaper Resources/Wallpapers
```

## 验证

```sh
lipo -archs build/诗栖.app/Contents/MacOS/ShiQi
codesign --verify --deep --strict build/诗栖.app
mkdir -p outputs
build/诗栖.app/Contents/MacOS/ShiQi --self-test
arch -x86_64 build/诗栖.app/Contents/MacOS/ShiQi --self-test
```

最后一条可在装有 Rosetta 的 Apple Silicon Mac 上验证 Intel 代码路径，不能取代实际 Intel 硬件验收。自检会临时修改并恢复本机设置，建议先退出正在运行的诗栖。系统分享、视频播放、登录启动及多屏仍需人工验收。

## 参考

- [Apple：构建通用 macOS 二进制](https://developer.apple.com/documentation/apple-silicon/building-a-universal-macos-binary)
- [Homebrew Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)

原创代码及自制示例素材采用 MIT 许可证。古诗正文为公版作品。
