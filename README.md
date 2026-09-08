# NotesMy 📌

> **Your AI-Powered Second Brain for macOS — Smart notes with Knowledge Graph, iCloud Sync & Voice Transcription.**  
> Built natively with Swift 6, AppKit, SwiftUI & Apple Intelligence. Zero clutter, zero subscriptions, zero tracking.

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-black?style=flat&logo=apple)](https://apple.com)
[![Homebrew Cask](https://img.shields.io/badge/Homebrew-Cask-blue?style=flat&logo=homebrew)](https://github.com/mehmetefeaytas/homebrew-tap)
[![Apple Intelligence](https://img.shields.io/badge/Apple%20Intelligence-Ready-purple?style=flat&logo=apple)](README.md)
[![Languages](https://img.shields.io/badge/Languages-12-orange)](README.md)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20On--Device-green)](README.md)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen)](README.md)

---

![NotesMy — AI-Powered Second Brain for macOS](assets/hero_banner.jpg)

---

## ⚡ Quick Install via Homebrew

```bash
brew install --cask mehmetefeaytas/tap/notesmy
```

| | |
|---|---|
| **Upgrade** | `brew upgrade --cask notesmy` |
| **Uninstall** | `brew uninstall --cask notesmy` |
| **Direct download** | [GitHub Releases →](https://github.com/mehmetefeaytas/notesmy/releases) |

> ⚠️ **Gatekeeper note (first launch):** Right-click the app → **Open** → click Open. Or run:  
> `xattr -dr com.apple.quarantine /Applications/NotesMy.app`

---

## 🌍 12 Languages Supported

NotesMy automatically detects your system language on first launch and switches the full UI instantly — no restart required.

| | Language | Voice Transcription |
|---|---|---|
| 🇬🇧 | English | ✅ en-US |
| 🇹🇷 | Türkçe | ✅ tr-TR |
| 🇩🇪 | Deutsch | ✅ de-DE |
| 🇫🇷 | Français | ✅ fr-FR |
| 🇪🇸 | Español | ✅ es-ES |
| 🇧🇷 | Português (Brasil) | ✅ pt-BR |
| 🇮🇹 | Italiano | ✅ it-IT |
| 🇷🇺 | Русский | ✅ ru-RU |
| 🇯🇵 | 日本語 | ✅ ja-JP |
| 🇰🇷 | 한국어 | ✅ ko-KR |
| 🇸🇦 | العربية (RTL) | ✅ ar-SA |
| 🇨🇳 | 中文 (简体) | ✅ zh-CN |

---

## 🌟 What's New in v1.5.0

![Notes Grid — Filters, Tags & Checklists](assets/feature_notes.jpg)

| Feature | Description |
|---------|-------------|
| 🕰️ **Version History** | Full snapshot timeline per note — restore any version with one click |
| 📋 **Note Templates** | 5 bilingual built-in templates (Meeting, Daily Planner, Code Review, Brainstorm, Bug Report) |
| 🌐 **Knowledge Graph** | 2D node canvas from `[[wiki links]]` — drag, zoom, double-click to open (`⌥⌘G`) |
| 🤖 **AI Second Brain** | Chat with your entire note collection — Q&A, daily plan, task extraction |
| ☁️ **iCloud CloudKit Sync** | Real-time sync across Apple devices, full offline support |
| 🌍 **Web Clipper** | Copy URL → instant formatted note with title, source & timestamp |
| 📅 **Calendar Export** | `.ics` export — opens in Calendar.app, Google Calendar, Outlook |
| ✏️ **Freehand Sketch** | Native AppKit canvas for mouse, trackpad & Apple Pencil via Sidecar |
| 🔗 **Wiki Links & Backlinks** | `[[Note Title]]` bidirectional links with backlinks strip in editor |
| 💬 **Note Comments** | Timestamped comment threads, full history per note |

---

## 🧠 AI & Intelligence Features

![AI Second Brain Chat & Knowledge Graph](assets/feature_ai.jpg)

### 🤖 AI Second Brain Chat
Chat naturally with your entire note collection. Ask *"What are my tasks for this week?"* or *"Summarize my meeting notes from last month"* — NotesMy semantically searches all your notes and synthesizes an answer, all on-device.

### 🌐 Knowledge Graph
Write `[[Note Title]]` anywhere in a note to create a bidirectional link. The Knowledge Graph view renders all your notes as an interactive 2D node canvas, showing how your ideas connect. Drag nodes, zoom, double-click to open any note.

### 🧹 Format & Clean Messy Notes
Dump raw thoughts and click **AI › Format & Organize**. On-device AI structures your braindump into paragraphs, bullet points, and an interactive checklist.

### 📜 Smart Summary
One-click executive summaries from long notes, meeting transcripts, or lecture notes. Powered by on-device NaturalLanguage processing.

### 🔍 Semantic Search
Find notes even without exact keywords. Toggle **Semantic Search** to match notes by concept, meaning, and synonyms using Apple `NLEmbedding`.

### 💡 Smart Title & Auto-Categorize
Click **AI › Suggest Smart Title** or **AI › Auto-Categorize** to classify notes into Work, Code, Ideas, or Personal — automatically.

---

## 🎙️ Voice Notes & Live Transcription

![Voice Notes with Live Transcription](assets/feature_voice.jpg)

Record voice notes hands-free with live transcription happening **100% on-device** using Apple `SFSpeechRecognizer`. Works in all 12 supported languages — the speech engine automatically uses the locale matching your current app language.

- 🎤 Real-time waveform visualization
- 📝 Live transcript appears as you speak
- ✅ Transcription auto-appended to your note
- 🌍 Switches speech locale when you change app language

---

## 📌 Sticky Board Canvas

![Sticky Board — Freeform Corkboard Canvas](assets/feature_board.jpg)

Open the **Sticky Board** (`⌥⌘B`) for a freeform corkboard where you drag notes anywhere, zoom in/out, and organize spatially. Great for brainstorming, project planning, and visual thinking.

---

## 🚀 The 3-Stage Edge Interaction

```
[Screen Edge]
     │
     ├─ 1. At Rest  — 14pt translucent pill. Zero screen obstruction, 0% CPU.
     │
     ├─ 2. Hover    — Fanned deck slides out with spring animation.
     │                Shows titles, colors & checklist progress bars.
     │
     └─ 3. Write    — Glassmorphic editor with Apple Intelligence Writing Tools,
                      markdown checkboxes, date detection, voice, OCR & AI actions.
```

---

## ✨ Full Feature Matrix

| Category | Features |
|----------|---------|
| 📝 **Notes** | Text, Checklist, Colors (6 palettes), Tags, Pin, Favorites, Archive |
| 🎨 **Appearance** | 5 fonts, size slider (11–22pt), 3 card size presets, dark/light mode |
| 🔍 **Search** | Lexical + Semantic (`NLEmbedding`), filter tabs, color filters, full-text |
| 🤖 **AI** | Format, Summarize, Extract Tasks, Smart Title, Auto-Categorize, Second Brain Chat |
| 🎙️ **Voice** | 12-language recording, live transcription, waveform meter |
| 📸 **Capture** | Interactive screenshot, Vision OCR, Web Clipper, freehand sketch |
| 🔗 **Links** | `[[Wiki Links]]`, Knowledge Graph 2D canvas, backlinks strip |
| ☁️ **Sync** | iCloud CloudKit (private DB), offline-first, background sync |
| 📅 **Export** | Markdown, single TXT, .ics Calendar, Apple Notes, Reminders |
| 🔔 **Reminders** | Native `UNUserNotificationCenter` alerts with exact date/time |
| 🕰️ **History** | Version snapshots, restore, note comments timeline |
| 📋 **Templates** | 5 bilingual built-ins + custom template support |
| ⌨️ **Shortcuts** | `⌥⌘N/V/L/B/A/G`, `⌘[/]/./Esc`, hotkey customization |
| 🛡️ **Privacy** | 100% local & offline, no telemetry, no accounts required |

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `⌥⌘N` | Create new sticky note |
| `⌥⌘V` | Quick Capture from clipboard |
| `⌥⌘L` | Open All Notes & Search Library |
| `⌥⌘B` | Open 2D Sticky Board Canvas |
| `⌥⌘G` | Open Knowledge Graph |
| `⌥⌘A` | Open Archive |
| `⌃⌥⌘H` | Toggle edge deck visibility |
| `⌘[` / `⌘]` | Flip through notes |
| `⌘.` | Cycle note color theme |
| `Esc` | Close active note editor |

---

## 🛠️ Building from Source

### Prerequisites
- macOS 13.0+ (Universal Binary: Apple Silicon + Intel)
- Xcode 15+ / Swift 6.0 toolchain

```bash
# Clone
git clone https://github.com/mehmetefeaytas/notesmy.git
cd notesmy

# Run tests (9 tests)
swift test

# Build & package DMG (Universal Binary)
./package_dmg.sh

# Open DMG
open NotesMy-1.5.0.dmg
```

### Release a new version
```bash
git tag v1.6.0 && git push origin main --tags
# GitHub Actions automatically: tests → builds → packages → releases → updates Homebrew tap
```

---

## 📋 Changelog

### v1.5.0 — Second Brain & Knowledge Graph
Version History, Templates, Knowledge Graph, AI Second Brain Chat, iCloud CloudKit Sync, Web Clipper, Calendar Export, Freehand Sketch, Wiki Links & Backlinks, Note Comments, **12-language support**

### v1.4.0 — Multi-Language & Voice
Turkish/English UI, Sticky Board Canvas, Voice Notes (live transcription), Screenshot Capture, Vision OCR, AI Cleanup & Summary, Semantic Search, Typography settings, Reminders, Modern Settings

### v1.3.0 — Smart Capture
Clipboard History Hub, Apple Notes export, Reminders export, Code Mode, Accordion Fold, Multi-display support

---

## 🤝 Contributing

Contributions, feature suggestions, and bug reports are welcome!

1. Fork the project
2. Create your feature branch: `git checkout -b feature/AmazingFeature`
3. Commit: `git commit -m 'Add AmazingFeature'`
4. Push: `git push origin feature/AmazingFeature`
5. Open a Pull Request

---

## 📄 License

Licensed under the **Apache License, Version 2.0**. See [`LICENSE`](LICENSE).

Developed with ❤️ by [Mehmet Efe Aytaş](https://github.com/mehmetefeaytas).
