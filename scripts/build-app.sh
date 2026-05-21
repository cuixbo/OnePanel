#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="OnePanel"
BUILD_DIR="$ROOT_DIR/.build/arm64-apple-macosx/debug"
APP_DIR="$ROOT_DIR/dist/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
PLIST_PATH="$CONTENTS_DIR/Info.plist"
ICON_PATH="$ROOT_DIR/Resources/AppIcon.icns"

cd "$ROOT_DIR"
swift scripts/generate-icons.swift
swift build

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"
cp "$ICON_PATH" "$RESOURCES_DIR/AppIcon.icns"

/usr/libexec/PlistBuddy -c "Add :CFBundleDevelopmentRegion string en" "$PLIST_PATH" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Clear dict" "$PLIST_PATH" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleExecutable string $APP_NAME" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string com.onepanel.app" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundleName string $APP_NAME" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundlePackageType string APPL" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 0.1.0" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string 1" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :LSMinimumSystemVersion string 14.0" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$PLIST_PATH"
/usr/bin/codesign --force --deep --sign - "$APP_DIR" >/dev/null

echo "Built app bundle at: $APP_DIR"
