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

## 菜单与更新

「搜索」下面是「其他功能」：收藏当前壁纸、收藏当前诗歌、收藏列表、历史记录、复制、截屏导出、保存壁纸、分享、动态壁纸、停止动态壁纸；最底部是「版本更新」。

「休息提醒与偏好设置」包含登录启动、调整诗歌显示、休息提醒、屏幕保护模式。「调整诗歌显示」包含字号、文字阴影浓度、字体颜色（预设及自定义）、诗词对齐、自动切换诗画。

点击「版本更新」会读取固定仓库的 GitHub 最新正式 Release。只有新版本号高于本机版本时才自动下载并安装，完成后重启；下载时可关闭进度窗口取消。下载来源限制为 GitHub，校验 Release 资产 SHA-256、应用标识、版本和签名结构；不降级、不自动清除 quarantine。目录不可写时打开已校验的 DMG，交由用户拖拽完成安装。当前仍为 ad-hoc 签名，校验不等同于 Apple 开发者身份认证。

个人素材在更新前保存到 `~/Library/Application Support/ShiQi/PrivateResources`，新版本继续加载该目录，避免被公开示例资源覆盖。设置和自定义诗词另存本机设置。成功安装后旧应用以隐藏的 `.ShiQi-backup-*.app` 保留在原目录，可用于手动恢复。重启失败时尝试回滚原应用；实际登录、多屏等系统特性仍需对应环境验收。

## 素材范围

公开发行版内置全部 3,045 篇古诗词正文及 3 张由本仓库程序生成的示例壁纸，不包含现代书籍赏析、第三方壁纸、用户收藏或本机个人文件。自定义诗词与设置仅保存在本机。

构建时可接入自己的资源目录。不要把无公开分发授权的素材提交到仓库或 Release。

## 从源码构建

需要 macOS、Apple Command Line Tools（`xcode-select --install`）及 Python 3；无第三方 Python/Swift 依赖。

```sh
python3 scripts/build.py --output build
python3 scripts/package_dmg.py build/诗栖.app build/ShiQi-1.3.1-universal.dmg
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

版本比较、来源限制与校验测试：`python3 scripts/test_models.py`。

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
