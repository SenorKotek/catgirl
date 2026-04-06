#!/usr/bin/env bash
set -euo pipefail

APP_NAME="app"
BUNDLE_NAME="${APP_NAME}.app"
BUILD_DIR=".build/release"
DIST_DIR="dist"
APP_DIR="${DIST_DIR}/${BUNDLE_NAME}"
MACOS_DIR="${APP_DIR}/Contents/MacOS"
RESOURCES_DIR="${APP_DIR}/Contents/Resources"
PLIST_PATH="${APP_DIR}/Contents/Info.plist"

printf '==> Building release binary with SwiftPM\n'
swift build -c release

BIN_PATH="${BUILD_DIR}/${APP_NAME}"
if [[ ! -f "${BIN_PATH}" ]]; then
  echo "Error: binary not found at ${BIN_PATH}" >&2
  exit 1
fi

printf '==> Creating app bundle at %s\n' "${APP_DIR}"
rm -rf "${APP_DIR}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

cp "${BIN_PATH}" "${MACOS_DIR}/${APP_NAME}"
chmod +x "${MACOS_DIR}/${APP_NAME}"

cat > "${PLIST_PATH}" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>local.catgirl.${APP_NAME}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

if command -v codesign >/dev/null 2>&1; then
  printf '==> Applying ad-hoc signature\n'
  codesign --force --deep --sign - "${APP_DIR}" >/dev/null
fi

printf '\nDone. App bundle ready: %s\n' "${APP_DIR}"
printf 'Run it on macOS with: open "%s"\n' "${APP_DIR}"
