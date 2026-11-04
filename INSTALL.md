# 诗栖安装说明

适用于 macOS 13 或更高版本。Universal 2 安装包同时包含 Apple Silicon（arm64）与 Intel（x86_64）原生程序；不需要按芯片下载不同版本。

## 拖拽安装

1. 打开 `.dmg` 磁盘映像。
2. 把「诗栖.app」拖到旁边的「Applications」快捷方式（即 `/Applications`）。
3. 从「应用程序」打开诗栖。默认直接展示桌面诗画，操作入口在菜单栏的山水图标中。
4. 弹出磁盘映像。更新时先从菜单栏退出旧版，再替换应用。

GitHub/Homebrew 公开版包含 3 首古诗和 3 张自制示例壁纸。个人完整素材版包含本机导入的诗库与壁纸，仅在本机提供，不上传公开 Release。

## macOS 安全提示与签名

当前版本采用临时（ad-hoc）签名，没有 Apple Developer ID 签名，也没有 Apple 公证。

本地验证签名结构完整性（不代表开发者身份认证）：

```sh
codesign --verify --deep --strict --verbose=2 /Applications/诗栖.app
```

若系统阻止打开，请先核对安装包来自你信任的仓库，并核对发布的 SHA-256。确认来源可信后，可按需在终端运行：

```sh
sudo xattr -r -d com.apple.quarantine /Applications/诗栖.app
```

此命令只移除隔离标记，可能绕过该应用的 Gatekeeper 隔离检查；它不会修复或验证数字签名，也不等同于 Apple 公证。不要对来源不明的应用使用。不需要关闭系统整体安全保护。若提示 `No such xattr`，通常表示该应用没有此隔离标记。

## Homebrew 安装

```sh
brew tap gxh259/shiqi https://github.com/gxh259/shiqi.git
brew install --cask gxh259/shiqi/shiqi
```

更新：

```sh
brew update
brew upgrade --cask gxh259/shiqi/shiqi
```

卸载：

```sh
brew uninstall --cask gxh259/shiqi/shiqi
```

Homebrew 安装的是公开示例版，保留系统正常安全检查，不自动清除隔离标记。通过 Homebrew 安装前，请先退出手动安装的同名应用；Homebrew 若报告同名应用已存在，请先备份并移走原应用。

## 登录项

在诗栖菜单栏勾选「登录时启动诗栖」。如系统要求授权，在系统设置的「通用 → 登录项」允许。登录项采用诗栖应用图标。建议先将应用装到 `/Applications` 再启用登录项，避免外置硬盘登录时未挂载。
