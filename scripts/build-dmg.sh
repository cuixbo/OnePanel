#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="OnePanel"
SCHEME="OnePanel"
PROJECT_PATH="$ROOT_DIR/OnePanel.xcodeproj"
BUILD_ROOT="$ROOT_DIR/.build/dmg"
DERIVED_DATA_PATH="$BUILD_ROOT/DerivedData"
ARCHIVE_ROOT="$BUILD_ROOT/archive"
EXPORT_ROOT="$ROOT_DIR/dist"
APP_PATH="$EXPORT_ROOT/$APP_NAME.app"
STAGING_DIR="$BUILD_ROOT/dmg-staging"
DMG_PATH="$EXPORT_ROOT/$APP_NAME.dmg"
VOLUME_NAME="$APP_NAME"

rm -rf "$BUILD_ROOT" "$APP_PATH" "$DMG_PATH"
mkdir -p "$ARCHIVE_ROOT" "$EXPORT_ROOT"

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -archivePath "$ARCHIVE_ROOT/$APP_NAME.xcarchive" \
  CODE_SIGNING_ALLOWED=NO \
  archive

cp -R "$ARCHIVE_ROOT/$APP_NAME.xcarchive/Products/Applications/$APP_NAME.app" "$APP_PATH"

rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
cp -R "$APP_PATH" "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "Built app bundle at: $APP_PATH"
echo "Built disk image at: $DMG_PATH"
