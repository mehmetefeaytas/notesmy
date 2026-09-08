#!/usr/bin/env bash
set -e

APP_NAME="NotesMy"
VERSION="1.5.2"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
STAGING_DIR="dmg_staging"

echo "🚀 1. Building Universal macOS Binary (arm64 + x86_64)..."
swift build -c release --arch arm64 --arch x86_64

echo "📦 2. Packaging ${APP_BUNDLE}..."
rm -rf "${APP_BUNDLE}" "${STAGING_DIR}" "${DMG_NAME}" "${APP_NAME}.dmg"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

cp ".build/apple/Products/Release/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"
cp "Resources/Info.plist" "${CONTENTS_DIR}/Info.plist"
echo -n "APPL????" > "${CONTENTS_DIR}/PkgInfo"

echo "🔏 3. Ad-hoc code signing..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "💿 4. Preparing DMG staging directory..."
mkdir -p "${STAGING_DIR}"
cp -R "${APP_BUNDLE}" "${STAGING_DIR}/"
ln -s /Applications "${STAGING_DIR}/Applications"

echo "🗜️ 5. Creating compressed DMG image (${DMG_NAME})..."
hdiutil create -volname "${APP_NAME}" -srcfolder "${STAGING_DIR}" -ov -format UDZO "${DMG_NAME}"
cp "${DMG_NAME}" "${APP_NAME}.dmg"

echo "🗜️ 6. Also packaging ${APP_NAME}.zip for alternative distribution..."
zip -r -q -y "${APP_NAME}.zip" "${APP_BUNDLE}"

rm -rf "${STAGING_DIR}"

echo "🔑 7. Calculating SHA-256 checksum..."
SHA_VALUE=$(shasum -a 256 "${DMG_NAME}" | awk '{print $1}')
echo "========================================================"
echo "✅ Build & DMG Packaging Succeeded!"
echo "📦 DMG File: ${DMG_NAME} (and ${APP_NAME}.dmg)"
echo "🔑 SHA256:  ${SHA_VALUE}"
echo "========================================================"
