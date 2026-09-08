# NotesMy 📌

> **Frictionless, edge-docked sticky notes and smart scratchpad for macOS.**  
> Built natively with Swift 6, AppKit, and SwiftUI. Zero clutter, zero subscriptions, zero tracking.

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-black?style=flat&logo=apple)](https://apple.com)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange?style=flat&logo=swift)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Local-green)](README.md)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen)](README.md)

---

## 🌟 Why NotesMy?

Traditional sticky notes clutter your workspace, get buried under app windows, and turn your desktop into visual noise. On the other hand, heavy markdown or note-taking apps like Notion or Obsidian demand deliberate window management and context-switching for quick thoughts.

**NotesMy** re-imagines quick scratchpads:
* It sleeps on the screen edge as an elegant, 14pt vertical pill with colored dashes.
* Reach for it with your mouse, and your notes **fan out smoothly** along the edge.
* Select any note to expand it in-place, write your thoughts, and watch it auto-save locally within 300ms.
* Packed with next-generation capabilities: **instant clipboard capture**, **smart date & calendar detection**, **interactive checklists**, and **multi-format exports**.

---

## 🚀 The 3-Stage Edge Interaction

```
[Screen Edge]
     │
     ├─ Step 1: At Rest (Dormant Pill)
     │   └─ Sits quietly as a 14pt translucent pill with colored indicator dashes.
     │      Zero screen obstruction, no dock clutter, 0% CPU at rest.
     │
     ├─ Step 2: Hover (Fanned Deck)
     │   └─ Moving pointer to edge fans out the cards down the screen with
     │      staggered spring animation, showing titles, colors & checklist progress.
     │
     └─ Step 3: Write (Expanded Editor)
         └─ Opens as a glassmorphic sticky note with full editing, checklist toggles,
            natural language date detection, and desktop pin capability.
```

---

## ✨ Features & Next-Gen Additions

### 1. ⚡ Instant Quick Capture (`⌥⌘V`)
Copy any link, snippet, or thought from your browser or terminal and hit `⌥⌘V`. NotesMy instantly parses your clipboard and creates a fresh sticky note ready in your deck.

### 2. 📅 Smart Natural Language Date & Calendar Detection
NotesMy scans your notes using native macOS linguistic data detectors. Mentioning *"Meeting tomorrow at 3:00 PM"* or *"Friday 10am"* automatically surfaces a 1-click **"Add to Calendar"** badge right inside the note.

### 3. ✅ Interactive Checklists & Markdown
Type `- [ ] ` or tap the checkbox button in the toolbar to create checklists. Checkboxes are interactive both in the full editor and as interactive quick-toggles directly on the note deck!

### 4. 📌 Freely Pin to Desktop
Want a reminder to stay permanently visible while coding or in a meeting? Click the **Pin** icon (`📌`) or drag the handle to peel the note off the edge and float it anywhere on your desktop.

### 5. 🎨 6 Curated Color Palettes
Every note carries its distinct visual tone:
- **Amber Yellow** (Classic warm sticky note)
- **Coral Pink** (Vibrant, high-priority tasks)
- **Mint Green** (Done / creative thoughts)
- **Sky Blue** (Readings & references)
- **Lavender Purple** (Brainstorming & personal)
- **Slate Noir** (Minimalist dark mode paper)

### 6. 🔍 Unified "All Notes" Library & Search (`⌥⌘L`)
A dedicated two-pane library window to browse, search, and filter your entire history by **Active**, **Archived**, or specific colors. Includes 10-second undo protection for accidental deletions.

### 7. 📤 Multi-Format Export
Export individual notes or your entire workspace into:
- Individual Markdown files (`.md`)
- Plain text (`.txt`)
- Combined single document (`NotesMy_Export.txt`)

### 8. 🛡️ Zero-Permission Security Architecture
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
- macOS 13.0 or later (Tested on macOS 14 Sonoma, 15 Sequoia, and newer)
- Xcode 15+ / Swift 6.0 toolchain

### Build via Swift Package Manager
```bash
# Clone the repository
git clone https://github.com/mehmetefeaytas/notesmy.git
cd notesmy

# Run test suite
swift test

# Build and package NotesMy.app bundle
chmod +x build_app.sh
./build_app.sh

# Launch the application
open NotesMy.app
```

---

## 🏗️ Project Architecture

```
notesmy/
├── Package.swift                    # Swift 6 SPM manifest
├── build_app.sh                     # Automated packaging & codesigning script
├── Resources/
│   └── Info.plist                   # LSUIElement accessory app configuration
├── Sources/
│   └── NotesMy/
│       ├── App/
│       │   ├── NotesMy.swift        # Main entrypoint
│       │   └── AppDelegate.swift    # App lifecycle & global hotkey binding
│       ├── Models/
│       │   ├── NoteItem.swift       # Note data model, checklists & attachments
│       │   ├── NoteColor.swift      # 6 curated theme palettes & color extensions
│       │   └── SmartDateDetector.swift # NLP date & calendar event detection
│       ├── Services/
│       │   ├── NoteStore.swift      # Debounced auto-save, CRUD & export engine
│       │   ├── ClipboardService.swift # Instant clipboard capture service
│       │   └── HotKeyManager.swift  # Zero-permission Carbon hotkey bridge
│       ├── Views/
│       │   ├── EdgeDeckView.swift   # Resting pill & fanned spring stack UI
│       │   ├── NoteEditorView.swift # Full-featured floating editor & checklists
│       │   ├── AllNotesWindowView.swift # Split-view library & search
│       │   └── SettingsView.swift   # Preferences, docking & hotkey guide
│       ├── Windows/
│       │   ├── EdgeDeckWindowManager.swift  # Floating NSPanel on screen edge
│       │   ├── NoteWindowManager.swift      # Movable sticky note panels
│       │   ├── AllNotesWindowManager.swift  # Standard library window
│       │   └── SettingsWindowManager.swift  # Preferences window
│       └── MenuBar/
│           └── MenuBarController.swift      # Menu bar status item & quick actions
└── Tests/
    └── NotesMyTests/
        └── NotesMyTests.swift       # Swift Testing suite (CRUD, NLP, Colors)
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

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.

Developed with ❤️ by [Mehmet Efe Aytaş](https://github.com/mehmetefeaytas).
