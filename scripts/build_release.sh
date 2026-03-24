#!/usr/bin/env bash

set -euo pipefail
export COPYFILE_DISABLE=1

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${DEVMAID_DIST_DIR:-${ROOMSERVICE_DIST_DIR:-$ROOT_DIR/dist}}"
WORK_DIR="${DEVMAID_WORK_DIR:-${ROOMSERVICE_WORK_DIR:-$ROOT_DIR/.release-work}}"
VERSION_FILE="$ROOT_DIR/VERSION"

if [[ -f "$VERSION_FILE" ]]; then
  DEFAULT_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
else
  DEFAULT_VERSION="0.1.0"
fi

VERSION="${1:-${DEVMAID_VERSION:-${ROOMSERVICE_VERSION:-$DEFAULT_VERSION}}}"
PACKAGE_IDENTIFIER="${DEVMAID_PACKAGE_IDENTIFIER:-${ROOMSERVICE_PACKAGE_IDENTIFIER:-app.devmaid.cli}}"
APP_IDENTIFIER="${DEVMAID_APP_IDENTIFIER:-${ROOMSERVICE_APP_IDENTIFIER:-app.devmaid.desktop}}"
SIGNING_IDENTITY="${DEVMAID_SIGNING_IDENTITY:-${ROOMSERVICE_SIGNING_IDENTITY:-}}"
NOTARY_PROFILE="${DEVMAID_NOTARY_KEYCHAIN_PROFILE:-${ROOMSERVICE_NOTARY_KEYCHAIN_PROFILE:-}}"
HOMEBREW_URL="${DEVMAID_HOMEBREW_URL:-${ROOMSERVICE_HOMEBREW_URL:-}}"
UPDATE_FEED_URL="${DEVMAID_UPDATE_FEED_URL:-${ROOMSERVICE_UPDATE_FEED_URL:-https://github.com/your-org/devmaid/releases/latest/download/appcast.json}}"
ARCHIVE_BASENAME="devmaid-${VERSION}"
APP_PRODUCT="DevMaidApp"
APP_EXECUTABLE_NAME="DevMaid"
APP_BUNDLE_NAME="DevMaid.app"
APP_ICON_PATH="$ROOT_DIR/Sources/RoomServiceApp/Resources/AppIcon.icns"

prune_bundle_xattrs() {
  local target="$1"
  xattr -cr "$target" 2>/dev/null || true
  xattr -dr com.apple.FinderInfo "$target" 2>/dev/null || true
  xattr -dr 'com.apple.fileprovider.fpfs#P' "$target" 2>/dev/null || true
}

sign_artifact() {
  local target="$1"
  if [[ -n "$SIGNING_IDENTITY" ]]; then
    if [[ "$target" == *.app ]]; then
      codesign --force --deep --options runtime --sign "$SIGNING_IDENTITY" "$target"
    else
      codesign --force --sign "$SIGNING_IDENTITY" "$target"
    fi
  else
    if [[ "$target" == *.app ]]; then
      codesign --force --deep --sign - "$target"
    else
      codesign --force --sign - "$target"
    fi
  fi
}

notarize_artifact() {
  local target="$1"
  local staple_target="${2:-}"

  if [[ -z "$SIGNING_IDENTITY" || -z "$NOTARY_PROFILE" ]]; then
    return
  fi

  echo "Submitting $(basename "$target") for notarization..."
  xcrun notarytool submit "$target" --keychain-profile "$NOTARY_PROFILE" --wait

  if [[ -n "$staple_target" ]]; then
    echo "Stapling notarization ticket to $(basename "$staple_target")..."
    xcrun stapler staple "$staple_target"
  fi
}

if [[ -n "${DEVMAID_ARCHS:-${ROOMSERVICE_ARCHS:-}}" ]]; then
  read -r -a ARCHS <<< "${DEVMAID_ARCHS:-${ROOMSERVICE_ARCHS:-}}"
else
  ARCHS=("$(uname -m)")
fi

rm -rf "$WORK_DIR"
mkdir -p "$DIST_DIR" "$WORK_DIR"

if [[ ! -f "$APP_ICON_PATH" ]]; then
  "$ROOT_DIR/scripts/generate_brand_assets.swift"
fi

CLI_BINARIES=()
APP_BINARIES=()
APP_RESOURCE_BUNDLE=""

for ARCH in "${ARCHS[@]}"; do
  CLI_SCRATCH_PATH="$WORK_DIR/cli-build-$ARCH"
  APP_SCRATCH_PATH="$WORK_DIR/app-build-$ARCH"

  echo "Building devmaid CLI for $ARCH..."
  swift build \
    -c release \
    --product devmaid \
    --arch "$ARCH" \
    --scratch-path "$CLI_SCRATCH_PATH"
  CLI_RELEASE_DIR="$(find "$CLI_SCRATCH_PATH" -type d -path '*/release' | head -n 1)"
  CLI_BINARIES+=("$CLI_RELEASE_DIR/devmaid")

  echo "Building DevMaid desktop app for $ARCH..."
  swift build \
    -c release \
    --product "$APP_PRODUCT" \
    --arch "$ARCH" \
    --scratch-path "$APP_SCRATCH_PATH"
  APP_RELEASE_DIR="$(find "$APP_SCRATCH_PATH" -type d -path '*/release' | head -n 1)"
  APP_BINARIES+=("$APP_RELEASE_DIR/$APP_PRODUCT")

  if [[ -z "$APP_RESOURCE_BUNDLE" ]]; then
    APP_RESOURCE_BUNDLE="$(find "$APP_RELEASE_DIR" -maxdepth 1 -name '*.bundle' | head -n 1)"
  fi
done

CLI_UNIVERSAL_BINARY="$WORK_DIR/devmaid"
APP_UNIVERSAL_BINARY="$WORK_DIR/$APP_EXECUTABLE_NAME"

if [[ "${#CLI_BINARIES[@]}" -eq 1 ]]; then
  cp "${CLI_BINARIES[0]}" "$CLI_UNIVERSAL_BINARY"
  cp "${APP_BINARIES[0]}" "$APP_UNIVERSAL_BINARY"
  ARTIFACT_ARCH="${ARCHS[0]}"
else
  echo "Creating universal binaries..."
  lipo -create "${CLI_BINARIES[@]}" -output "$CLI_UNIVERSAL_BINARY"
  lipo -create "${APP_BINARIES[@]}" -output "$APP_UNIVERSAL_BINARY"
  ARTIFACT_ARCH="universal"
fi
chmod +x "$CLI_UNIVERSAL_BINARY" "$APP_UNIVERSAL_BINARY"

ARCHIVE_ROOT="$WORK_DIR/archive-root"
mkdir -p "$ARCHIVE_ROOT"
cp "$CLI_UNIVERSAL_BINARY" "$ARCHIVE_ROOT/devmaid"
cp "$ROOT_DIR/README.md" "$ARCHIVE_ROOT/README.md"
cp "$ROOT_DIR/LICENSE" "$ARCHIVE_ROOT/LICENSE"

TARBALL_PATH="$DIST_DIR/${ARCHIVE_BASENAME}-macos-${ARTIFACT_ARCH}.tar.gz"
tar -czf "$TARBALL_PATH" -C "$ARCHIVE_ROOT" devmaid README.md LICENSE

APP_BUNDLE_DIR="$WORK_DIR/$APP_BUNDLE_NAME"
APP_CONTENTS_DIR="$APP_BUNDLE_DIR/Contents"
APP_MACOS_DIR="$APP_CONTENTS_DIR/MacOS"
APP_RESOURCES_DIR="$APP_CONTENTS_DIR/Resources"
mkdir -p "$APP_MACOS_DIR" "$APP_RESOURCES_DIR"
cp "$APP_UNIVERSAL_BINARY" "$APP_MACOS_DIR/$APP_EXECUTABLE_NAME"
cp "$APP_ICON_PATH" "$APP_RESOURCES_DIR/AppIcon.icns"
cp -R "$APP_RESOURCE_BUNDLE" "$APP_RESOURCES_DIR/"

cat > "$APP_CONTENTS_DIR/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>${APP_EXECUTABLE_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>${APP_IDENTIFIER}</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>DevMaid</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${VERSION}</string>
  <key>CFBundleVersion</key>
  <string>${VERSION}</string>
  <key>LSApplicationCategoryType</key>
  <string>public.app-category.developer-tools</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>DevMaidUpdateFeedURL</key>
  <string>${UPDATE_FEED_URL}</string>
</dict>
</plist>
EOF

if [[ -n "$SIGNING_IDENTITY" ]]; then
  prune_bundle_xattrs "$APP_BUNDLE_DIR"
  sign_artifact "$APP_BUNDLE_DIR"
else
  prune_bundle_xattrs "$APP_BUNDLE_DIR"
  sign_artifact "$APP_BUNDLE_DIR"
fi
prune_bundle_xattrs "$APP_BUNDLE_DIR"

rm -rf "$DIST_DIR/$APP_BUNDLE_NAME"
ditto "$APP_BUNDLE_DIR" "$DIST_DIR/$APP_BUNDLE_NAME"
prune_bundle_xattrs "$DIST_DIR/$APP_BUNDLE_NAME"

DMG_ROOT="$WORK_DIR/dmg-root"
mkdir -p "$DMG_ROOT"
ditto "$APP_BUNDLE_DIR" "$DMG_ROOT/$APP_BUNDLE_NAME"
prune_bundle_xattrs "$DMG_ROOT/$APP_BUNDLE_NAME"

cat > "$DMG_ROOT/README.txt" <<EOF
DevMaid ${VERSION}

This DMG ships the DevMaid desktop app.

Install:
1. Drag DevMaid.app to Applications
2. Open DevMaid from Applications
3. Use Homebrew or the CLI tarball if you also want the terminal binary

CLI installation still uses the tarball/Homebrew flow.
EOF

cat > "$DMG_ROOT/Install DevMaid.command" <<EOF
#!/bin/bash
set -euo pipefail
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
open "\$SCRIPT_DIR/DevMaid.app"
EOF
chmod +x "$DMG_ROOT/Install DevMaid.command"

DMG_PATH="$DIST_DIR/DevMaid-${VERSION}.dmg"
hdiutil create \
  -volname "DevMaid ${VERSION}" \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

if [[ -n "$SIGNING_IDENTITY" ]]; then
  sign_artifact "$DMG_PATH"
fi

notarize_artifact "$DMG_PATH" "$DMG_PATH"

prune_bundle_xattrs "$APP_BUNDLE_DIR"
prune_bundle_xattrs "$DIST_DIR/$APP_BUNDLE_NAME"

CHECKSUMS_PATH="$DIST_DIR/checksums-${VERSION}.txt"
shasum -a 256 "$TARBALL_PATH" "$DMG_PATH" > "$CHECKSUMS_PATH"

if [[ -n "$HOMEBREW_URL" ]]; then
  "$ROOT_DIR/scripts/generate_homebrew_formula.sh" \
    --version "$VERSION" \
    --url "$HOMEBREW_URL" \
    --archive "$TARBALL_PATH" \
    --output "$DIST_DIR/devmaid.rb"
fi

echo ""
echo "Artifacts ready in $DIST_DIR"
echo "- $TARBALL_PATH"
echo "- $DIST_DIR/$APP_BUNDLE_NAME"
echo "- $DMG_PATH"
echo "- $CHECKSUMS_PATH"
if [[ -n "$HOMEBREW_URL" ]]; then
  echo "- $DIST_DIR/devmaid.rb"
fi
if [[ -n "$SIGNING_IDENTITY" && -n "$NOTARY_PROFILE" ]]; then
  echo "Notarization: complete"
elif [[ -n "$SIGNING_IDENTITY" ]]; then
  echo "Notarization: skipped (set DEVMAID_NOTARY_KEYCHAIN_PROFILE to enable)"
fi
