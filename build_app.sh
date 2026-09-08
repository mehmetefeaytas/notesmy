#!/usr/bin/env bash
set -e

echo "🚀 Building NotesMy (Release)..."
swift build -c release

APP_NAME="NotesMy"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "📦 Packaging ${APP_BUNDLE}..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

cp ".build/release/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"
cp "Resources/Info.plist" "${CONTENTS_DIR}/Info.plist"
echo -n "APPL????" > "${CONTENTS_DIR}/PkgInfo"

echo "🔏 Ad-hoc code signing..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "🗜️ Creating release zip..."
zip -r -q -y "${APP_NAME}.zip" "${APP_BUNDLE}"

echo "✅ Build complete! Output: ${APP_BUNDLE} and ${APP_NAME}.zip"
