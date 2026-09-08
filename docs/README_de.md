# 🇩🇪 NotesMy — KI-gestütztes Second Brain & Haftnotizen für macOS

<p align="center">
  <img src="../assets/app_icon_1024.png" alt="NotesMy App Icon" width="128" height="128" style="border-radius: 28px; box-shadow: 0 8px 24px rgba(0,0,0,0.25);" />
</p>

<h2 align="center">Reibungslose Haftnotizen am Bildschirmrand & Persönliches Wissensmanagement für macOS</h2>

<p align="center">
  <a href="../README.md">🇬🇧 English</a> · 
  <a href="README_tr.md">🇹🇷 Türkçe</a> · 
  <strong>[🇩🇪 Deutsch](README_de.md)</strong> · 
  <a href="README_fr.md">🇫🇷 Français</a> · 
  <a href="README_es.md">🇪🇸 Español</a> · 
  <a href="README_pt.md">🇧🇷 Português</a> · 
  <a href="README_it.md">🇮🇹 Italiano</a> · 
  <a href="README_ru.md">🇷🇺 Русский</a> · 
  <a href="README_ja.md">🇯🇵 日本語</a> · 
  <a href="README_ko.md">🇰🇷 한국어</a> · 
  <a href="README_ar.md">🇸🇦 العربية</a> · 
  <a href="README_zh.md">🇨🇳 中文</a>
</p>

<p align="center">
  <a href="https://github.com/mehmetefeaytas/notesmy/releases"><img src="https://img.shields.io/github/v/release/mehmetefeaytas/notesmy?style=for-the-badge&color=8B5CF6" alt="Release" /></a>
  <a href="https://github.com/mehmetefeaytas/homebrew-tap"><img src="https://img.shields.io/badge/Homebrew-Cask%20Verfügbar-orange?style=for-the-badge&logo=homebrew" alt="Homebrew" /></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?style=for-the-badge&logo=apple" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift" alt="Swift 6" />
  <img src="https://img.shields.io/badge/Architektur-Universal%20(ARM64%20%2B%20x86__64)-green?style=for-the-badge" alt="Universal Binary" />
  <img src="https://img.shields.io/badge/Datenschutz-100%25%20Lokal%20On--Device-success?style=for-the-badge" alt="Datenschutz" />
  <img src="https://img.shields.io/badge/Lizenz-Apache%202.0-yellow?style=for-the-badge" alt="Apache 2.0" />
</p>

---

## 🎬 Kinoreife Live-Demo

<p align="center">
  <img src="../assets/demo.gif" alt="NotesMy Live Demo" width="100%" style="border-radius: 12px; box-shadow: 0 12px 36px rgba(0,0,0,0.25);" />
</p>
<p align="center">
  <em>Hochauflösende Bildschirmaufnahme: Sanftes Hereingleiten vom Bildschirmrand, Schnellnotizen, interaktives Notiz-Board und sofortige OCR-Texterkennung. (<a href="../assets/demo.mp4">60fps MP4 Herunterladen</a>)</em>
</p>

---

## ⚡ Was ist NotesMy?

**NotesMy** ist eine ultraschnelle, native macOS-Anwendung für Haftnotizen und persönliches Wissensmanagement. Sie schließt die Lücke zwischen schnellen Notizzetteln (wie *Unclutter* und *SideNotes*) und tiefgehenden Wissensdatenbanken (wie *Obsidian* und *Apple Notes*).

Zu 100 % nativ in **Swift 6, SwiftUI und AppKit** entwickelt, bleibt NotesMy unaufdringlich in Ihrer Menüleiste und gleitet elegant vom Bildschirmrand hervor, sobald Sie es aufrufen.

### ✨ Wichtigste Highlights

- 🪟 **Bildschirmrand-Dock (Edge Deck):** Fahren Sie mit der Maus an den Bildschirmrand, um alle aktiven Notizen in einem animierten Fächer-Dock anzuzeigen.
- 🔄 **In-App-Updates:** Direkte Überprüfung von GitHub-Releases in den Einstellungen, Changelog-Ansicht, DMG-Download-Fortschrittsbalken und 1-Klick-Aktualisierung.
- ⌨️ **Tastaturnavigation für Kategorien:** Sanftes Blättern durch Kategorien und Filter mit den Pfeiltasten (`←` / `→`) und Klick-Schaltflächen.
- 🗑️ **Schnelllöschen & Inaktive Notizen bereinigen:** Notizen mit einem Klick direkt auf der Karte löschen; automatische Erkennung und Archivierung von Notizen, die seit >30 Tagen ungenutzt sind.
- ⚙️ **Sichere Fensterverwaltung:** Das rote Schließsymbol der Einstellungen beendet die App niemals; zweistufige Sicherheitsabfrage vor dem Zurücksetzen von Daten.
- 🧠 **Mathematischer KI-Wissensgraph:** Coulomb-Hooke-Physiksimulation, Jaccard-Konzeptähnlichkeit, bidirektionale `[[WikiLinks]]` und leuchtende durchgezogene Farblinien bei Auswahl.
- 🔍 **Bildschirm-OCR & Vision-KI:** Beliebigen Bildschirmbereich auswählen, um Texte sofort in die Zwischenablage oder Notiz zu extrahieren.
- 🎙️ **Lokale Sprachaufnahme:** Echtzeit-Spracherkennung mit Unterstützung für 12 Sprachen ohne Latenz und ohne Datenschutzrisiko.
- 📌 **Freies Notiz-Board:** Notizen auf einer unendlichen, zoombaren und ziehbaren Pinnwand frei anordnen.
- 🎨 **Minimalistische Pastellpaletten:** 6 harmonische macOS-Pastellfarben, Rich-Markdown-Formatierung, Checklisten und Code-Hervorhebung.
- 🛡️ **Keine Telemetrie & 100 % Offline:** Kein Tracking, keine Cloud-Zwänge. Alle NLP- und Bilderkennungsmodelle laufen lokal auf Ihrem Mac.

---

## 🍺 Installation via Homebrew

Der empfohlene Weg zur Installation und Aktualisierung unter macOS:

```bash
# 1. Benutzerdefiniertes Homebrew-Repository hinzufügen
brew tap mehmetefeaytas/tap

# 2. NotesMy installieren
brew install --cask notesmy
```

### Aktualisierung
```bash
brew upgrade --cask notesmy
```

### Manuelle Installation (DMG)
Möchten Sie das Universal-DMG direkt herunterladen? Die neueste Version finden Sie unter [GitHub Releases](https://github.com/mehmetefeaytas/notesmy/releases/latest).

> **Gatekeeper-Hinweis (Erster Start):** Da NotesMy als quelloffene Binärdatei vertrieben wird, zeigt macOS beim ersten Start möglicherweise einen Sicherheitshinweis an. Klicken Sie einfach mit der rechten Maustaste auf `NotesMy.app` in `/Applications` und wählen Sie **Öffnen**, oder führen Sie im Terminal aus:
> ```bash
> xattr -cr /Applications/NotesMy.app
> ```

---

## 📸 Einblicke in die Benutzeroberfläche

<table width="100%">
  <tr>
    <td width="50%">
      <h3 align="center">🗂️ Alle Notizen & Semantische Suche</h3>
      <img src="../assets/preview-allnotes.png" alt="NotesMy Hauptfenster" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🪟 Bildschirmrand-Dock</h3>
      <img src="../assets/preview-edge-deck.png" alt="NotesMy Edge Deck" width="100%" />
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3 align="center">📝 Minimalistischer Notizeditor</h3>
      <img src="../assets/preview-note.png" alt="NotesMy Notizeditor" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🎨 Modernes Pastell-App-Icon</h3>
      <img src="../assets/app_icon_1024.png" alt="NotesMy Icon" width="60%" style="display: block; margin: 0 auto;" />
    </td>
  </tr>
</table>

---

## 💎 Vollständige Funktionsübersicht

| Stufe | Funktion | Status | Technologie |
| :--- | :--- | :---: | :--- |
| **V1 — Basis** | Text- & Checklisten-Notizen mit Pastell-Themen | ✅ | Natives SwiftUI TextEditor |
| **V1 — Basis** | Bildschirmrand-Dock (Fächerkarten) | ✅ | AppKit Schwebendes NSPanel |
| **V1 — Basis** | Schlagwörter, Kategorien, Anpinnen & Favoriten | ✅ | Lokale JSON-Speicherung |
| **V1 — Basis** | Tastaturnavigation (`←` / `→`) durch Kategorien | ✅ | AppKit Event Monitor + ScrollViewReader |
| **V1 — Basis** | Schnelllöschung direkt auf der Notizkarte | ✅ | Swift Action Handler |
| **V1 — Basis** | Zwischenablage-Verlauf mit automatischer Erfassung | ✅ | NSPasteboard Monitor |
| **V1 — Basis** | Interaktiver Farbwähler & größenveränderbare Fenster | ✅ | AppKit NSWindow + SwiftUI |
| **V2 — Erweitert** | Mehrsprachige Sprachnotizen (Transkription) | ✅ | Apple SFSpeechRecognizer |
| **V2 — Erweitert** | Vision-OCR Textextraktion durch Bereichsschnitt | ✅ | Apple Vision + screencapture |
| **V2 — Erweitert** | Interaktives, freies Notiz-Board | ✅ | SwiftUI Drag & Drop Canvas |
| **V2 — Erweitert** | Bereinigung & Archivierung inaktiver Notizen (>30 Tage) | ✅ | Veralterungs-Erkennungsmodul |
| **V2 — Erweitert** | Natürliche Datums- & Erinnerungserkennung | ✅ | NSDataDetector + UserNotifications |
| **V2 — Erweitert** | Semantische Vektorsuche nach Konzepten | ✅ | Apple NaturalLanguage Embeddings |
| **V3 — Verbunden** | Integrierte Auto-Updates & GitHub-Versionsprüfung | ✅ | GitHub REST API + URLSession |
| **V3 — Verbunden** | Web-Clipper für URLs mit Textauszug | ✅ | WebKit + URLSession |
| **V3 — Verbunden** | 1-Klick Kalenderexport (.ics) | ✅ | RFC 5545 Kalender-Generator |
| **V3 — Verbunden** | Export zu Apple Notizen & Erinnerungen | ✅ | NSSharingService + EventKit |
| **V3 — Verbunden** | Privater CloudKit-Abgleich & lokale Sicherung | ✅ | Apple CloudKit Container |
| **V3 — Verbunden** | Versionsverlauf mit Zeitleisten-Wiederherstellung | ✅ | Inkrementelle Snapshots |
| **V4 — Second Brain** | Physikalischer Coulomb-Hooke KI-Wissensgraph | ✅ | Mathematische Simulation + Canvas |
| **V4 — Second Brain** | Durchgezogene, leuchtende Farblinien bei Auswahl | ✅ | SwiftUI Vektor-Graphenpfade |
| **V4 — Second Brain** | Bidirektionale `[[WikiLinks]]` mit Backlink-Index | ✅ | Regex Link-Parser |
| **V4 — Second Brain** | Lokaler KI-Chat über den gesamten Notizbestand | ✅ | Lokales NaturalLanguage RAG |
| **V4 — Second Brain** | Automatische Tagesplan- & Aufgabenextraktion | ✅ | NLP Task Extraction |
| **V4 — Second Brain** | Gedanken bereinigen & automatische Formatierung | ✅ | Apple Intelligence NLP Engine |

---

## 🌍 Unterstützte Sprachen (12 Sprachen)

NotesMy erkennt die macOS-Systemsprache automatisch und bietet vollständige Benutzeroberflächen und Sprachunterstützung:

| Flagge | Sprache | Flagge | Sprache | Flagge | Sprache |
| :---: | :--- | :---: | :--- | :---: | :--- |
| 🇬🇧 | English | 🇹🇷 | Türkçe | 🇩🇪 | Deutsch |
| 🇫🇷 | Français | 🇪🇸 | Español | 🇧🇷 | Português (Brasilien) |
| 🇮🇹 | Italiano | 🇷🇺 | Русский | 🇯🇵 | 日本語 |
| 🇰🇷 | 한국어 | 🇸🇦 | العربية (RTL) | 🇨🇳 | 简体中文 |

---

## ⌨️ Globale Tastatur-Kurzbefehle

Alle Kurzbefehle können unter **Einstellungen → Kurzbefehle** angepasst werden:

| Tastenkombination | Aktion | Beschreibung |
| :--- | :--- | :--- |
| `⌥⌘N` | **Neue Notiz** | Öffnet sofort eine schwebende Haftnotiz auf dem Bildschirm |
| `⌥⌘V` | **Schnellerfassung** | Wandelt Zwischenablagen-Inhalte in eine neue Notiz um |
| `⌥⌘L` | **Alle Notizen & Suche** | Öffnet das Hauptfenster mit semantischer Suche |
| `⌥⌘B` | **Notiz-Board** | Öffnet die freie, zoombare Pinnwand |
| `⌥⌘A` | **Archiv** | Zeigt archivierte Notizen an |
| `⌃⌥⌘H` | **Dock umschalten** | Blendet das Bildschirmrand-Dock ein oder aus |
| `Esc` | **Notiz schließen** | Schließt das aktive Notizfenster |

---

## 📈 Star-Entwicklung

[![Star History Chart](https://api.star-history.com/svg?repos=mehmetefeaytas/notesmy&type=Date)](https://star-history.com/#mehmetefeaytas/notesmy&Date)

---

## 👥 Mitwirkende

Beiträge, Funktionsvorschläge und Fehlerberichte sind herzlich willkommen!

<a href="https://github.com/mehmetefeaytas/notesmy/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=mehmetefeaytas/notesmy" alt="Contributors" />
</a>

Richtlinien und Testanweisungen finden Sie in [CONTRIBUTING.md](../CONTRIBUTING.md).

---

## 💖 Sponsoren & Unterstützung

Wenn NotesMy Ihren Arbeitsablauf auf dem Mac bereichert, freuen wir uns über Ihre Unterstützung:

<p align="center">
  <a href="https://github.com/sponsors/mehmetefeaytas"><img src="https://img.shields.io/badge/GitHub%20Sponsors-Unterst%C3%BCtzen-EA4AAA?style=for-the-badge&logo=githubsponsors" alt="GitHub Sponsors" /></a>
</p>

---

## 📬 Kontakt & Vernetzung

Für Feedback, Fragen und Zusammenarbeit:

- 📧 **E-Mail:** [efeyapiyor@gmail.com](mailto:efeyapiyor@gmail.com)
- 💼 **LinkedIn:** [Mehmet Efe Aytaş](https://linkedin.com/in/mehmetefeaytas)
- 🐙 **GitHub:** [@mehmetefeaytas](https://github.com/mehmetefeaytas)

---

## 🛡️ Datenschutz & Architektur

- **Vollständig offline:** NotesMy funktioniert zu 100 % ohne Serververbindung. Keine Telemetrie, kein Tracking.
- **Lokale Dateispeicherung:** Alle Daten liegen als sauberes JSON unter `~/Library/Application Support/NotesMy/notes.json`.
- **CloudKit-Synchronisation:** Die optionale Synchronisation läuft ausschließlich über Ihren privaten iCloud-Container.

---

## 📄 Lizenz

NotesMy steht unter der **Apache License 2.0**. Weitere Informationen in der Datei [LICENSE](../LICENSE).

Entwickelt mit ❤️ von **[Mehmet Efe Aytaş](https://github.com/mehmetefeaytas)**.
