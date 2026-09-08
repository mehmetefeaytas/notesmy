# NotesMy 📌

> **Frictionless, edge-docked sticky notes and smart scratchpad for macOS.**  
> Powered natively by Swift 6, AppKit, SwiftUI, and **Apple Intelligence**. Zero clutter, zero subscriptions, zero tracking.

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-black?style=flat&logo=apple)](https://apple.com)
[![Homebrew Cask](https://img.shields.io/badge/Homebrew-Cask-blue?style=flat&logo=homebrew)](https://github.com/mehmetefeaytas/homebrew-tap)
[![Apple Intelligence](https://img.shields.io/badge/Apple%20Intelligence-Ready-purple?style=flat&logo=apple)](README.md)
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

## 🌟 Why NotesMy?

Traditional sticky notes clutter your workspace, get buried under app windows, and turn your desktop into visual noise. On the other hand, heavy markdown or note-taking apps like Notion or Obsidian demand deliberate window management and context-switching for quick thoughts.

**NotesMy** combines the best concepts from **HoldMyNotes**, **SideNotes**, **Tot**, and **Unclutter**, seamlessly infused with **Apple Intelligence**:
* It sleeps on the screen edge as an elegant, 14pt vertical pill with colored dashes.
* Reach for it with your mouse, and your notes **fan out smoothly** along the edge.
* Select any note to expand it in-place, write your thoughts, and watch it auto-save locally within 300ms.
* **Now with Multi-Display & Apple Notes Integration**: Follows your cursor across multiple connected screens, and lets you 1-click export to Apple Notes and Apple Reminders!

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

<p align="center">
  <img src="assets/preview-allnotes.png" width="700" alt="NotesMy All Notes Window & Live Editor" />
</p>

---

## 🧠 Apple Intelligence & On-Device AI Features

### 🪄 1. Native macOS Writing Tools Integration
On macOS 15+ Sequoia and macOS 26, NotesMy activates native system **Apple Intelligence Writing Tools** (`.writingToolsBehavior(.complete)`). Select text or right-click to trigger Proofread, Rewrite, Friendly, Professional, Summary, or Table generation directly inside your sticky notes!

### 🎯 2. Instant Action Item Extraction
Have messy meeting notes or a braindump? Click **AI › Extract Action Items** to automatically scan your text and generate an interactive `- [ ] ` checklist at the top of your note.

### 📜 3. On-Device TL;DR Summarization
Turn long thoughts into punchy executive summaries with 1 click using on-device NaturalLanguage processing.

### 💡 4. Smart Title & Category Prediction
Never worry about naming notes again. Click **AI › Suggest Smart Title** or **AI › Auto-Categorize** to let on-device AI classify your thoughts into *Work*, *Code*, *Ideas*, or *Personal*.

### ✍️ 5. Tone & Structure Rewriter
Easily polish your text into **Concise & Punchy**, **Professional**, or **Bullet Points** without sending a single byte to external cloud servers.

---

## ✨ Full Feature Matrix

### 🖥️ Multi-Display & Cursor Following
Seamlessly supports dual or triple monitor setups. As your pointer moves between displays, NotesMy automatically aligns with the edge of your active monitor so notes are always right where your attention is.

### 🍎 Apple Notes & Reminders 1-Click Bridge
Need to push your scratchpad thought into your permanent knowledge base or task list?
- Tap the **Apple Notes** button to instantly create a note in your Apple Notes account.
- Tap the **Reminders** button to turn tasks into macOS Reminders with due dates!

### 📂 Folders & Topic Collections *(SideNotes inspired)*
Organize your scratchpad notes by topics: **Work**, **Personal**, **Code**, **Ideas**, and **General**. Filter the active deck with one click directly at the top of the edge fan, or view by collection in the All Notes library.

### 📋 Clipboard History Hub *(Unclutter inspired)*
Never lose a snippet. Click the clipboard icon on the deck or menu bar to open your recent clipboard history and convert any copied text or URL into a fresh sticky note with 1 click. Or hit `⌥⌘V` anywhere for instant capture.

### 🪟 Adjustable Window Translucency & Glassmorphism *(Noticky inspired)*
Working on UI design or copying code from a browser window behind your note? Use the built-in Opacity Slider (40%–100%) to make your sticky notes translucent and see right through them.

### 🗂️ Accordion Fold / Minimize *(SideNotes inspired)*
Need a pinned sticky note on your screen without taking up space? Tap the fold arrow (`⌃`) to collapse the note into just a slender header bar. Click again to expand anytime.

### 💻 Monospaced Code Mode *(SideNotes inspired)*
Working with shell commands, API endpoints, or code snippets? Toggle **Code Mode** (`</>`) to format the note in a clean monospaced typeface with 1-click code copying.

### 📅 Smart NLP Date & Calendar Detection
NotesMy scans your notes using native macOS linguistic data detectors. Mentioning *"Meeting tomorrow at 3:00 PM"* or *"Friday 10am"* automatically surfaces a 1-click **"Add to Calendar"** badge right inside the note.

### ✅ Interactive Checklists & Markdown
Type `- [ ] ` or tap the checkbox button in the toolbar to create checklists. Checkboxes are interactive both in the full editor and as interactive quick-toggles directly on the note deck!

### 📌 Freely Pin to Desktop
Want a reminder to stay permanently visible while coding or in a meeting? Click the **Pin** icon (`📌`) or drag the handle to peel the note off the edge and float it anywhere on your desktop.

### 📤 Native macOS Sharing Sheet & Multi-Format Export *(Tot inspired)*
Share notes directly to Mail, Messages, Apple Notes, or AirDrop using the native macOS Share Sheet (`NSSharingServicePicker`). Or batch export to Markdown (`.md`), Plain Text (`.txt`), or combined archives.

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
open NotesMy-1.3.0.dmg
```

---

## 🏗️ Project Architecture

```
notesmy/
├── Package.swift                    # Swift 6 SPM manifest
├── package_dmg.sh                   # Universal DMG packaging & checksum script
├── .github/workflows/
│   └── release.yml                  # Automated CI/CD release & Homebrew tap sync
├── Resources/
│   └── Info.plist                   # LSUIElement accessory app configuration
├── Sources/
│   └── NotesMy/
│       ├── App/
│       │   ├── NotesMy.swift        # Main entrypoint
│       │   └── AppDelegate.swift    # App lifecycle & global hotkey binding
│       ├── Models/
│       │   ├── NoteItem.swift       # Note model, categories, folding & opacity
│       │   ├── NoteColor.swift      # 6 curated theme palettes & color extensions
│       │   └── SmartDateDetector.swift # NLP date & calendar event detection
│       ├── Services/
│       │   ├── AppleNotesService.swift # Apple Notes & Reminders AppleScript bridge
│       │   ├── SmartAIService.swift # Apple Intelligence & on-device NLP processing
│       │   ├── NoteStore.swift      # Debounced auto-save, categories & clipboard hub
│       │   ├── ClipboardService.swift # Instant clipboard capture service
│       │   └── HotKeyManager.swift  # Zero-permission Carbon hotkey bridge
│       ├── Views/
│       │   ├── EdgeDeckView.swift   # Resting pill & fanned spring stack UI
│       │   ├── NoteEditorView.swift # Editor with Apple Intelligence & Writing Tools
│       │   ├── AllNotesWindowView.swift # Split-view library & category filters
│       │   └── SettingsView.swift   # Preferences, docking & hotkey guide
│       ├── Windows/
│       │   ├── EdgeDeckWindowManager.swift  # Multi-display floating panel
│       │   ├── NoteWindowManager.swift      # Movable sticky note panels
│       │   ├── AllNotesWindowManager.swift  # Standard library window
│       │   └── SettingsWindowManager.swift  # Preferences window
│       └── MenuBar/
│           └── MenuBarController.swift      # Status item & clipboard history menu
└── Tests/
    └── NotesMyTests/
        └── NotesMyTests.swift       # Swift Testing suite (CRUD, AI, NLP, Colors)
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
