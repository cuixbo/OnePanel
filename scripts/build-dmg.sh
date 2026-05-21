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
STAGING_DIR="$BUILD_ROOT/dmg-staging"
ARCHIVED_APP_PATH="$ARCHIVE_ROOT/$APP_NAME.xcarchive/Products/Applications/$APP_NAME.app"
STAGING_APP_PATH="$STAGING_DIR/$APP_NAME.app"
DMG_PATH="$EXPORT_ROOT/$APP_NAME.dmg"
VOLUME_NAME="$APP_NAME"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
TRANSIENT_APP_PATH="$DERIVED_DATA_PATH/Build/Intermediates.noindex/ArchiveIntermediates/$APP_NAME/InstallationBuildProductsLocation/Applications/$APP_NAME.app"

cleanup() {
  if [[ -x "$LSREGISTER" && -e "$TRANSIENT_APP_PATH" ]]; then
    "$LSREGISTER" -u "$TRANSIENT_APP_PATH" >/dev/null 2>&1 || true
  fi
  rm -rf "$BUILD_ROOT"
}

trap cleanup EXIT

rm -rf "$BUILD_ROOT" "$EXPORT_ROOT/$APP_NAME.app" "$DMG_PATH"
mkdir -p "$ARCHIVE_ROOT" "$EXPORT_ROOT"

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -archivePath "$ARCHIVE_ROOT/$APP_NAME.xcarchive" \
  CODE_SIGNING_ALLOWED=NO \
  archive

rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
cp -R "$ARCHIVED_APP_PATH" "$STAGING_APP_PATH"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "Built disk image at: $DMG_PATH"
