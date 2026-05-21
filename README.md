# OnePanel

OnePanel is a lightweight local-only macOS utility for keeping one always-available plain-text work panel.

## Current MVP

- Menu bar entry
- Single plain-text editor panel
- Local auto-save
- Pin / unpin top-most behavior
- Cross-space panel visibility configuration
- `ESC` hide behavior
- Remembered window frame and pin state
- Configurable global hotkey
- Lightweight settings window

## Development

### Open in Xcode

Open [OnePanel.xcodeproj](/Volumes/D/xbc/iOSProjects/OnePanel/OnePanel.xcodeproj) in Xcode and run the `OnePanel` scheme on `My Mac`.

The Xcode project is generated from [project.yml](/Volumes/D/xbc/iOSProjects/OnePanel/project.yml) using `xcodegen`.

### Regenerate the Xcode project

```bash
xcodegen generate
```

### Regenerate app icons

```bash
swift scripts/generate-icons.swift
```

The icon pipeline uses this source image as the master artwork:

```text
Resources/SourceArt/onepanel-master-icon.png
```

### Run tests

```bash
swift test
```

### Run Xcode build and tests from the command line

```bash
xcodebuild -project OnePanel.xcodeproj -scheme OnePanel -destination 'platform=macOS' build
xcodebuild -project OnePanel.xcodeproj -scheme OnePanel -destination 'platform=macOS' test
```

### Build

```bash
swift build
```

### Launch during development

```bash
swift run
```

### Build a local `.app` bundle

```bash
./scripts/build-app.sh
```

The generated app bundle is written to:

```text
dist/OnePanel.app
```

### Build and launch the app bundle

```bash
./scripts/run-app.sh
```

## Data Storage

The app stores its local document and settings in the user's Application Support directory under:

```text
~/Library/Application Support/OnePanel
```
