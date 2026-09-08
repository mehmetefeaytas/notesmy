# NotesMy 📌

> **Smart notes with AI Second Brain, Knowledge Graph, iCloud Sync & Voice Transcription for macOS.**  
> Powered natively by Swift 6, AppKit, SwiftUI, and **Apple Intelligence**. Zero clutter, zero subscriptions, zero tracking.

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-black?style=flat&logo=apple)](https://apple.com)
[![Homebrew Cask](https://img.shields.io/badge/Homebrew-Cask-blue?style=flat&logo=homebrew)](https://github.com/mehmetefeaytas/homebrew-tap)
[![Apple Intelligence](https://img.shields.io/badge/Apple%20Intelligence-Ready-purple?style=flat&logo=apple)](README.md)
[![Language](https://img.shields.io/badge/Languages-EN%20%7C%20TR-orange)](README.md)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20On--Device-green)](README.md)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen)](README.md)

---

## ⚡ Quick Install via Homebrew

You can install NotesMy with a single command via [Homebrew](https://brew.sh):

```bash
brew install --cask mehmetefeaytas/tap/notesmy
```

To upgrade later:
```bash
brew upgrade --cask notesmy
```

To uninstall cleanly:
```bash
brew uninstall --cask notesmy
```

Or download the universal `.dmg` installer directly from the [Releases page](https://github.com/mehmetefeaytas/notesmy/releases).

---

## 🌟 What's New in v1.5.0 — Second Brain & Knowledge Graph 🧠

- 🕰️ **Version History:** Every note keeps a full snapshot timeline — restore any previous version with one click. Auto-snapshots before template apply or AI edits.
- 📋 **Note Templates:** 5 built-in bilingual templates (Meeting Notes, Daily Planner, Code Review, Brainstorm, Bug Report). Apply in one tap from the editor header.
- 🌐 **Knowledge Graph:** Visual 2D canvas auto-generated from `[[Note Title]]` wiki links. Drag nodes, zoom, and double-click to open any note directly (`⌥⌘G`).
- 🤖 **AI Second Brain Chat:** Chat with your entire note collection. Semantic Q&A, daily plan generation, task extraction, and idea synthesis — all on-device.
- ☁️ **iCloud CloudKit Sync:** Real-time sync across all your Apple devices using the CloudKit private database. Full offline support with background sync.
- 🌍 **Web Clipper:** Copy any URL → click clip button → instant formatted note with title, source, and timestamp.
- 📅 **Calendar Export:** Export note dates as `.ics` files — opens directly in Calendar.app (compatible with Google Calendar & Outlook).
- ✏️ **Freehand Sketch Canvas:** Native AppKit drawing view in every note. Works with mouse, trackpad, and Apple Pencil via Sidecar. Saves as PNG attachment.
- 🔗 **Wiki Links & Backlinks:** Write `[[Note Title]]` to create bidirectional links between notes. Backlinks strip shown at the bottom of the editor.
- 💬 **Note Comments:** Timestamped comment threads per note. Full comment history preserved.

### Previous: v1.4.0

- 🇹🇷 **Multi-Language (EN / TR):** Full UI localization with on-the-fly language switching.
- 📌 **2D Sticky Board Canvas:** Freeform corkboard with draggable sticky cards, pushpins, and pan/zoom (`⌥⌘B`).
- 🎙️ **Voice Notes & Transcription:** On-device `SFSpeechRecognizer` with Turkish & English support.
- 📸 **Screenshot Capture:** Interactive screen selection with instant note attachment.
- 🔍 **Vision OCR:** Extract text from images using the Apple Vision framework.
- 🧠 **AI Note Cleanup & Smart Summary:** One-click braindump structuring and summaries.
- ⚡ **Semantic Search:** `NLEmbedding`-powered conceptual search.
- 🔤 **Typography & Card Sizes:** 5 fonts, adjustable size slider, 3 card size presets.
- 🔔 **Reminders:** Native `UNUserNotificationCenter` alerts.
- ⚙️ **Modern Multi-Tab Settings:** Live typography preview panel.

---



## 🚀 The 3-Stage Edge Interaction

```
[Screen Edge]
     │
     ├─ Step 1: At Rest (Dormant Pill)
     │   └─ Sits quietly as a 14pt translucent pill with colored indicator dashes.
     │      Zero screen obstruction, no dock clutter, 0% CPU at rest.
     │
     ├─ Step 2: Hover (Fanned Deck & Category Filter)
     │   └─ Moving pointer to edge fans out the cards down the screen with
     │      staggered spring animation, showing titles, colors & checklist progress.
     │
     └─ Step 3: Write (Glassmorphic Editor + Apple Intelligence)
         └─ Full in-place editing, Apple Intelligence Writing Tools, markdown checkboxes,
            opacity slider, natural language date detection, code mode, and desktop pin.
```

---

## 🧠 Apple Intelligence & On-Device AI Features

### 🪄 1. Native macOS Writing Tools Integration
On macOS 15+ Sequoia and macOS 26, NotesMy activates native system **Apple Intelligence Writing Tools** (`.writingToolsBehavior(.complete)`). Select text or right-click to trigger Proofread, Rewrite, Friendly, Professional, Summary, or Table generation directly inside your sticky notes!

### 🧹 2. Format & Clean Up Messy Braindumps
Dump unorganized thoughts into a note and click **AI › Format & Organize Messy Note**. On-device AI extracts main takeaways, formats structured paragraphs, and turns to-dos into an interactive `- [ ] ` checklist.

### 📜 3. On-Device Executive Summarization
Turn lengthy meeting transcripts or lectures into punchy executive summaries with 1 click using on-device NaturalLanguage processing.

### 🔍 4. Semantic Concept Search
Find notes even if you don't remember the exact keywords. Toggle **Semantic Search** in the search library to match notes by meaning, concepts, and synonyms using Apple `NLEmbedding`.

### 💡 5. Smart Title & Category Prediction
Never worry about naming notes again. Click **AI › Suggest Smart Title** or **AI › Auto-Categorize** to let on-device AI classify your thoughts into *Work*, *Code*, *Ideas*, or *Personal*.

---

## ✨ Full Feature Matrix

### 📌 2D Sticky Board Canvas
Need a spatial view of your thoughts? Open the **Sticky Board** (`⌥⌘B` or via toolbar) to view a corkboard canvas where you can freely drag cards around, zoom in and out, and organize by categories.

### 🎙️ Voice Notes with Live Speech-to-Text
Tap the microphone button to dictate notes hands-free. Transcription happens 100% on-device with zero latency, supporting both Turkish (`tr-TR`) and English (`en-US`).

### 📸 Direct Screenshot & Vision OCR
Click the camera icon to select any region of your screen. The screenshot is saved locally into your note attachments. Tap the OCR button (`text.viewfinder`) to extract all text directly into editable Markdown.

### 🔔 Native Notifications & Reminders
Set reminders with specific dates and times. NotesMy delivers local macOS notifications (`UNUserNotificationCenter`) that open the exact note when clicked.

### 🖥️ Multi-Display & Cursor Following
Seamlessly supports dual or triple monitor setups. As your pointer moves between displays, NotesMy automatically aligns with the edge of your active monitor so notes are always right where your attention is.

### 🍎 Apple Notes & Reminders 1-Click Bridge
- Tap the **Apple Notes** button to export directly to your Apple Notes account.
- Tap the **Reminders** button to turn tasks into macOS Reminders with due dates!

### 📋 Clipboard History Hub *(Unclutter inspired)*
Click the clipboard icon on the deck or menu bar to open your recent clipboard history and convert any copied text or URL into a fresh sticky note with 1 click. Or hit `⌥⌘V` anywhere for instant capture.

### 🪟 Adjustable Window Translucency *(Noticky inspired)*
Working on UI design or copying code from a browser behind your note? Use the built-in Opacity Slider (40%–100%) to make your sticky notes translucent.

### 🗂️ Accordion Fold / Minimize *(SideNotes inspired)*
Tap the fold arrow (`⌃`) to collapse the note into just a slender header bar.

### 💻 Monospaced Code Mode
Toggle **Code Mode** (`</>`) to format the note in a clean monospaced typeface with 1-click code copying.

### 🎨 6 Curated Color Palettes
- **Amber Yellow** (Classic warm sticky note)
- **Coral Pink** (Vibrant, high-priority tasks)
- **Mint Green** (Done / creative thoughts)
- **Sky Blue** (Readings & references)
- **Lavender Purple** (Brainstorming & personal)
- **Slate Noir** (Minimalist dark mode paper)

### 🛡️ Zero-Permission Security Architecture
- **No Accessibility permissions needed:** Registered via standard Carbon Hotkey APIs.
- **No Screen Recording or Input Monitoring:** Respects your privacy completely.
- **100% Local & Offline:** Notes are saved as JSON/plaintext in `~/Library/Application Support/NotesMy/`. No cloud accounts, telemetry, or third-party tracking.

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `⌥⌘N` | Create a new sticky note |
| `⌥⌘V` | **Quick Capture:** Create note from clipboard |
| `⌥⌘L` | Open All Notes & Search Library |
| `⌥⌘B` | Open 2D Sticky Board Canvas |
| `⌥⌘A` | Open Archive |
| `⌃⌥⌘H` | Toggle edge deck visibility |
| `⌘[` / `⌘]` | Flip through previous / next note in place |
| `⌘.` | Cycle sticky note color theme |
| `Esc` | Close active note editor |

---

## 🛠️ Building & Running from Source

### Prerequisites
- macOS 13.0 or later (Universal binary: Apple Silicon + Intel)
- Xcode 15+ / Swift 6.0 toolchain

### Build via Swift Package Manager
```bash
# Clone the repository
git clone https://github.com/mehmetefeaytas/notesmy.git
cd notesmy

# Run test suite
swift test

# Build universal DMG package
./package_dmg.sh

# Open DMG
open NotesMy-1.4.0.dmg
```

---

## 🤝 Contributing

Contributions, feature suggestions, and bug reports are welcome!
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Licensed under the **Apache License, Version 2.0** (the "License"). You may obtain a copy of the License in the [`LICENSE`](LICENSE) file.

Developed with ❤️ by [Mehmet Efe Aytaş](https://github.com/mehmetefeaytas).
