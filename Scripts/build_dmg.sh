#!/usr/bin/env bash
set -euo pipefail

# Builds PenguinTomato via Swift Package Manager and produces a DMG.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found. It is required for path safety checks." >&2
  exit 1
fi

safe_rm_rf() {
  for target in "$@"; do
    if [[ -z "$target" ]]; then
      echo "Refusing to remove an empty path" >&2
      exit 1
    fi

    local resolved
    resolved=$(python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$target") || {
      echo "Failed to resolve path: $target" >&2
      exit 1
    }

    case "$resolved" in
      "/"|"" )
        echo "Refusing to remove root directory" >&2
        exit 1
        ;;
      "$REPO_ROOT"|"$REPO_ROOT"/*)
        if [[ "$resolved" == "$REPO_ROOT" ]]; then
          echo "Refusing to remove the repository root" >&2
          exit 1
        fi
        ;;
      *)
        echo "Refusing to remove path outside repository: $resolved" >&2
        exit 1
        ;;
    esac

    if [[ -e "$resolved" ]]; then
      rm -rf "$resolved"
    fi
  done
}

cd "$REPO_ROOT"

if ! command -v swift >/dev/null 2>&1; then
  echo "swift not found. Install Xcode command line tools first." >&2
  exit 1
fi

if ! command -v hdiutil >/dev/null 2>&1; then
  echo "hdiutil not available on this system." >&2
  exit 1
fi

read -r -p "Version label (e.g. 1.0.0): " VERSION
VERSION=${VERSION:-dev}

read -r -p "Build output directory [.build]: " BUILD_DIR
BUILD_DIR=${BUILD_DIR:-.build}

read -r -p "Distribution output directory [dist]: " DIST_DIR
DIST_DIR=${DIST_DIR:-dist}

read -r -p "Clean previous build artifacts? [y/N]: " SHOULD_CLEAN
SHOULD_CLEAN=${SHOULD_CLEAN:-N}

read -r -p "Ad-hoc codesign the app? [y/N]: " SHOULD_CODESIGN
SHOULD_CODESIGN=${SHOULD_CODESIGN:-N}

APP_NAME="PenguinTomato"
BINARY_PATH="$BUILD_DIR/release/$APP_NAME"
RESOURCE_BUNDLE="$BUILD_DIR/release/${APP_NAME}_${APP_NAME}.bundle"
STAGE_DIR="$BUILD_DIR/${APP_NAME}-${VERSION}-staging"
APP_BUNDLE="$STAGE_DIR/${APP_NAME}.app"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
DMG_PATH="$DIST_DIR/$DMG_NAME"

if [[ "$SHOULD_CLEAN" =~ ^[Yy]$ ]]; then
  echo "\n▶︎ Cleaning previous build artifacts"
  safe_rm_rf "$BUILD_DIR" "$DIST_DIR"
fi

safe_rm_rf "$STAGE_DIR"
mkdir -p "$DIST_DIR"

if [ ! -x "$BINARY_PATH" ]; then
  echo "\n▶︎ Building release binary via swift build"
  swift build --configuration release
fi

if [ ! -x "$BINARY_PATH" ]; then
  echo "Expected binary not found at $BINARY_PATH" >&2
  exit 1
fi

if [ ! -d "$RESOURCE_BUNDLE" ]; then
  echo "Expected resource bundle not found at $RESOURCE_BUNDLE" >&2
  exit 1
fi

echo "\n▶︎ Assembling app bundle"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleDisplayName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>com.penguintomato.app</string>
  <key>CFBundleVersion</key>
  <string>${VERSION}</string>
  <key>CFBundleShortVersionString</key>
  <string>${VERSION}</string>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleSignature</key>
  <string>????</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
</dict>
</plist>
PLIST

cp "$BINARY_PATH" "$APP_BUNDLE/Contents/MacOS/${APP_NAME}"
chmod +x "$APP_BUNDLE/Contents/MacOS/${APP_NAME}"
cp -R "$RESOURCE_BUNDLE" "$APP_BUNDLE/Contents/Resources/"
cp Sources/${APP_NAME}/Resources/AppIcon.icns "$APP_BUNDLE/Contents/Resources/AppIcon.icns"

if [[ "$SHOULD_CODESIGN" =~ ^[Yy]$ ]]; then
  echo "\n▶︎ Applying ad-hoc codesign"
  if ! codesign --force --deep --sign - "$APP_BUNDLE"; then
    echo "⚠️  codesign reported warnings; continuing anyway." >&2
  fi
fi

echo "\n▶︎ Building DMG at $DMG_PATH"
rm -f "$DMG_PATH"
hdiutil create \
  -volname "${APP_NAME} ${VERSION}" \
  -srcfolder "$STAGE_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "\n✅ DMG created: $DMG_PATH"
echo "   (App bundle staged at $STAGE_DIR)"
