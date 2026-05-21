# OnePanel

OnePanel is a lightweight, local-first macOS menu bar utility for keeping one plain-text work panel always close at hand.

It is designed for the "quick capture, quick reference, quick hide" workflow: open a single scratch panel, write or paste text, and dismiss it without managing a full notes app.

## Highlights

- Menu bar app with a lightweight utility-style presence
- Single plain-text editor panel for fast capture and reference
- Local auto-save with no cloud dependency
- Pin and unpin support for keeping the panel above other windows
- Cross-Space visibility controls
- `Esc` to hide for quick dismissal
- Remembered window frame and pin state between launches
- Configurable global hotkey
- Separate settings window for basic behavior customization

## Current Status

OnePanel is currently an MVP focused on a narrow, polished core loop:

1. Open the panel quickly
2. Write or paste plain text
3. Hide it instantly
4. Come back to the same content later

There is no sync layer, account system, or rich-text formatting in the current version.

## Requirements

- macOS 14.0 or later
- Xcode 16 or later recommended for local development
- Swift 6 toolchain
- `xcodegen` for regenerating the Xcode project from `project.yml`

Install `xcodegen` if needed:

```bash
brew install xcodegen
```

## Getting Started

### Open in Xcode

Open [OnePanel.xcodeproj](/Volumes/D/xbc/iOSProjects/OnePanel/OnePanel.xcodeproj) in Xcode and run the `OnePanel` scheme on `My Mac`.

The checked-in Xcode project is generated from [project.yml](/Volumes/D/xbc/iOSProjects/OnePanel/project.yml).

### Run from the command line

```bash
swift run
```

### Build with SwiftPM

```bash
swift build
```

## Development

### Run tests

```bash
swift test
```

### Build and test with Xcode from the command line

```bash
xcodebuild -project OnePanel.xcodeproj -scheme OnePanel -destination 'platform=macOS' build
xcodebuild -project OnePanel.xcodeproj -scheme OnePanel -destination 'platform=macOS' test
```

### Regenerate the Xcode project

```bash
./scripts/regenerate-xcodeproj.sh
```

Equivalent direct command:

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

## Project Structure

```text
Sources/OnePanel         App entry points, models, services, and SwiftUI views
Tests/OnePanelTests      Unit tests for app behavior and persistence
Resources/               App icons and bundled assets
scripts/                 Development and packaging scripts
docs/                    Product notes, prototypes, and planning docs
project.yml              XcodeGen project definition
Package.swift            Swift Package Manager manifest
```

## Data Storage and Privacy

OnePanel is local-first. The app stores its document and settings in the user's Application Support directory:

```text
~/Library/Application Support/OnePanel
```

The current project does not include cloud sync, external backend services, or an account system.

## License

This project is licensed under the MIT License. See [LICENSE](/Volumes/D/xbc/iOSProjects/OnePanel/LICENSE).
