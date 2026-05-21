# OnePanel 开发说明

本文档面向需要参与开发、调试、构建和发布 OnePanel 的开发者。

## 开发环境

- macOS 14.0 及以上
- Xcode 16 及以上
- Swift 6 工具链
- `xcodegen`

安装 `xcodegen`：

```bash
brew install xcodegen
```

## 工程结构

```text
Sources/OnePanel         应用入口、模型、服务和 SwiftUI 视图
Tests/OnePanelTests      应用行为与持久化相关单元测试
Resources/               图标与打包资源
scripts/                 开发与打包脚本
docs/                    产品说明、原型和计划文档
project.yml              XcodeGen 工程定义
Package.swift            Swift Package Manager 清单
```

## 打开工程

用 Xcode 打开 [OnePanel.xcodeproj](/Volumes/D/xbc/iOSProjects/OnePanel/OnePanel.xcodeproj)，然后在 `My Mac` 上运行 `OnePanel` scheme。

仓库中提交的 Xcode 工程由 [project.yml](/Volumes/D/xbc/iOSProjects/OnePanel/project.yml) 生成。

## 命令行运行

```bash
swift run
```

## 使用 SwiftPM 构建

```bash
swift build
```

## 运行测试

```bash
swift test
```

## 使用 Xcode 命令行构建和测试

```bash
xcodebuild -project OnePanel.xcodeproj -scheme OnePanel -destination 'platform=macOS' build
xcodebuild -project OnePanel.xcodeproj -scheme OnePanel -destination 'platform=macOS' test
```

## 重新生成 Xcode 工程

```bash
./scripts/regenerate-xcodeproj.sh
```

等价命令：

```bash
xcodegen generate
```

## 图标相关

重新生成应用图标：

```bash
swift scripts/generate-icons.swift
```

图标流水线使用这张源图作为母图：

```text
Resources/SourceArt/onepanel-master-icon.png
```

## 本地构建 `.app`

```bash
./scripts/build-app.sh
```

输出路径：

```text
dist/OnePanel.app
```

## 本地构建 `.dmg`

```bash
./scripts/build-dmg.sh
```

输出路径：

```text
dist/OnePanel.dmg
```

## 构建并启动应用包

```bash
./scripts/run-app.sh
```

## GitHub DMG 发布

项目包含一个 GitHub Actions 工作流：[.github/workflows/build-dmg.yml](/Volumes/D/xbc/iOSProjects/OnePanel/.github/workflows/build-dmg.yml)。

它会在以下场景自动构建未签名的 `.dmg`：

- 手动触发 `workflow_dispatch`
- 推送匹配 `v*` 的 tag
- 发布 GitHub Release

工作流会上传 `dist/OnePanel.dmg` 作为 artifact，并在 tag/release 触发时把 DMG 挂到 GitHub Release。
