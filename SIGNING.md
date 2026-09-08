# Code Signing & Notarization Guide

> **Current status:** NotesMy is **ad-hoc signed** (free, no Apple account required for distribution).  
> This means users may see a Gatekeeper warning on first launch.  
> This guide explains how to upgrade to full **Developer ID + Notarization** when ready.

---

## What Users See Right Now (Ad-hoc)

When a user downloads the DMG and opens the app for the first time:

> *"NotesMy" cannot be opened because Apple cannot check it for malicious software.*

**Workaround for users (works on any macOS):**
```bash
# Option 1 — Right-click → Open → Open (GUI)

# Option 2 — Terminal (removes quarantine flag)
xattr -dr com.apple.quarantine /Applications/NotesMy.app
```

---

## Full Notarization Setup (Recommended for Public Distribution)

### Prerequisites

| What | Where to get it |
|------|-----------------|
| Apple Developer account | [developer.apple.com](https://developer.apple.com) — $99/year |
| **Developer ID Application** certificate | Xcode → Settings → Accounts → Manage Certificates |
| App-specific password | [appleid.apple.com](https://appleid.apple.com) → Security → App-specific passwords |

---

### Step 1 — Export your Developer ID certificate

1. Open **Keychain Access** → My Certificates
2. Find `Developer ID Application: Mehmet Efe Aytaş (TEAM_ID)`
3. Right-click → Export → save as `DeveloperID.p12` with a strong password
4. Base64-encode it for GitHub secrets:
   ```bash
   base64 -i DeveloperID.p12 | pbcopy   # copies to clipboard
   ```

---

### Step 2 — Add GitHub Secrets

Go to your repo → **Settings → Secrets and variables → Actions → New repository secret**:

| Secret name | Value |
|-------------|-------|
| `APPLE_CERT_BASE64` | Base64-encoded `.p12` content (step 1) |
| `APPLE_CERT_PASSWORD` | Password you set on the `.p12` |
| `APPLE_TEAM_ID` | Your 10-character team ID (visible in developer.apple.com) |
| `APPLE_ID` | Your Apple ID email |
| `APPLE_APP_PASSWORD` | App-specific password from appleid.apple.com |
| `TAP_GITHUB_TOKEN` | GitHub Fine-grained PAT with write access to `homebrew-tap` |

---

### Step 3 — Replace ad-hoc signing in `release.yml`

Replace the **"Build & Package DMG"** and **"Verify code signature"** steps with:

```yaml
      - name: Import Developer ID Certificate
        env:
          CERT_BASE64:    ${{ secrets.APPLE_CERT_BASE64 }}
          CERT_PASSWORD:  ${{ secrets.APPLE_CERT_PASSWORD }}
        run: |
          # Create a temporary keychain
          KEYCHAIN_PATH="$RUNNER_TEMP/notesmy.keychain-db"
          KEYCHAIN_PASSWORD=$(openssl rand -hex 16)
          security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
          security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
          security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

          # Import certificate
          echo "$CERT_BASE64" | base64 --decode > "$RUNNER_TEMP/cert.p12"
          security import "$RUNNER_TEMP/cert.p12" \
            -P "$CERT_PASSWORD" \
            -A -t cert -f pkcs12 \
            -k "$KEYCHAIN_PATH"

          # Make it the default
          security list-keychain -d user -s "$KEYCHAIN_PATH"
          echo "KEYCHAIN_PATH=$KEYCHAIN_PATH" >> $GITHUB_ENV

      - name: Build Universal Binary
        run: |
          swift build -c release --arch arm64 --arch x86_64

      - name: Package & Sign .app Bundle
        env:
          TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
        run: |
          VER="${{ steps.meta.outputs.version }}"
          APP="NotesMy.app"
          mkdir -p "${APP}/Contents/MacOS" "${APP}/Contents/Resources"
          cp ".build/apple/Products/Release/NotesMy" "${APP}/Contents/MacOS/"
          cp "Resources/Info.plist" "${APP}/Contents/"
          echo -n "APPL????" > "${APP}/Contents/PkgInfo"

          # Sign with Developer ID (hardened runtime required for notarization)
          codesign \
            --force --deep --options runtime \
            --sign "Developer ID Application: Mehmet Efe Aytaş (${TEAM_ID})" \
            --entitlements "Resources/NotesMy.entitlements" \
            "${APP}"

          codesign --verify --verbose "${APP}"
          echo "✅ App signed with Developer ID"

      - name: Create DMG
        run: |
          VER="${{ steps.meta.outputs.version }}"
          STAGING="dmg_staging"
          mkdir -p "$STAGING"
          cp -R NotesMy.app "$STAGING/"
          ln -s /Applications "$STAGING/Applications"
          hdiutil create \
            -volname "NotesMy" \
            -srcfolder "$STAGING" \
            -ov -format UDZO \
            "NotesMy-${VER}.dmg"
          cp "NotesMy-${VER}.dmg" NotesMy.dmg
          zip -r -q -y NotesMy.zip NotesMy.app
          rm -rf "$STAGING"

      - name: Notarize DMG
        env:
          APPLE_ID:          ${{ secrets.APPLE_ID }}
          APPLE_APP_PASSWORD: ${{ secrets.APPLE_APP_PASSWORD }}
          TEAM_ID:           ${{ secrets.APPLE_TEAM_ID }}
        run: |
          VER="${{ steps.meta.outputs.version }}"
          DMG="NotesMy-${VER}.dmg"

          echo "📤 Submitting for notarization..."
          xcrun notarytool submit "${DMG}" \
            --apple-id "${APPLE_ID}" \
            --password "${APPLE_APP_PASSWORD}" \
            --team-id "${TEAM_ID}" \
            --wait \
            --timeout 30m

          echo "📎 Stapling notarization ticket..."
          xcrun stapler staple "${DMG}"
          xcrun stapler validate "${DMG}"
          echo "✅ Notarization complete and stapled"
```

---

### Step 4 — Entitlements for Hardened Runtime

Your `Resources/NotesMy.entitlements` must include the hardened-runtime exceptions
needed by the app (audio, speech, network). The current file already covers these.

Verify with:
```bash
codesign -d --entitlements - NotesMy.app
```

---

### Step 5 — Test locally before pushing

```bash
# Sign locally with your Developer ID
codesign --force --deep --options runtime \
  --sign "Developer ID Application: Mehmet Efe Aytaş (YOUR_TEAM_ID)" \
  --entitlements Resources/NotesMy.entitlements \
  NotesMy.app

# Notarize
xcrun notarytool submit NotesMy-1.5.0.dmg \
  --apple-id "your@email.com" \
  --password "xxxx-xxxx-xxxx-xxxx" \
  --team-id "YOUR_TEAM_ID" \
  --wait

# Staple
xcrun stapler staple NotesMy-1.5.0.dmg
```

---

### What happens after notarization

- Users can open the app **without any warning**
- `brew install --cask mehmetefeaytas/tap/notesmy` works **silently**
- The app passes Gatekeeper automatically
- `spctl --assess --type execute NotesMy.app` returns **accepted**
