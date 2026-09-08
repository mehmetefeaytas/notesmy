# 🇮🇹 NotesMy — Secondo Cervello IA & Note Adesive per macOS

<p align="center">
  <img src="../assets/app_icon_1024.png" alt="NotesMy App Icon" width="128" height="128" style="border-radius: 28px; box-shadow: 0 8px 24px rgba(0,0,0,0.25);" />
</p>

<h2 align="center">Note adesive fluide ancorate al bordo dello schermo & Gestione della conoscenza per macOS</h2>

<p align="center">
  <a href="../README.md">🇬🇧 English</a> · 
  <a href="README_tr.md">🇹🇷 Türkçe</a> · 
  <a href="README_de.md">🇩🇪 Deutsch</a> · 
  <a href="README_fr.md">🇫🇷 Français</a> · 
  <a href="README_es.md">🇪🇸 Español</a> · 
  <a href="README_pt.md">🇧🇷 Português</a> · 
  <strong>[🇮🇹 Italiano](README_it.md)</strong> · 
  <a href="README_ru.md">🇷🇺 Русский</a> · 
  <a href="README_ja.md">🇯🇵 日本語</a> · 
  <a href="README_ko.md">🇰🇷 한국어</a> · 
  <a href="README_ar.md">🇸🇦 العربية</a> · 
  <a href="README_zh.md">🇨🇳 中文</a>
</p>

<p align="center">
  <a href="https://github.com/mehmetefeaytas/notesmy/releases"><img src="https://img.shields.io/github/v/release/mehmetefeaytas/notesmy?style=for-the-badge&color=8B5CF6" alt="Release" /></a>
  <a href="https://github.com/mehmetefeaytas/homebrew-tap"><img src="https://img.shields.io/badge/Homebrew-Cask%20Disponibile-orange?style=for-the-badge&logo=homebrew" alt="Homebrew" /></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?style=for-the-badge&logo=apple" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift" alt="Swift 6" />
  <img src="https://img.shields.io/badge/Architettura-Universale%20(ARM64%20%2B%20x86__64)-green?style=for-the-badge" alt="Binario Universale" />
  <img src="https://img.shields.io/badge/Privacy-100%25%20Sul--Dispositivo-success?style=for-the-badge" alt="Privacy" />
  <img src="https://img.shields.io/badge/Licenza-Apache%202.0-yellow?style=for-the-badge" alt="Apache 2.0" />
</p>

---

## 🎬 Dimostrazione Video

<p align="center">
  <img src="../assets/demo.gif" alt="NotesMy Dimostrazione video" width="100%" style="border-radius: 12px; box-shadow: 0 12px 36px rgba(0,0,0,0.25);" />
</p>
<p align="center">
  <em>Registrazione schermo ad alta definizione: Scorrimento fluido dal bordo del monitor, acquisizione rapida delle note, bacheca interattiva e riconoscimento OCR istantaneo. (<a href="../assets/demo.mp4">Scarica MP4 a 60fps</a>)</em>
</p>

---

## ⚡ Che cos'è NotesMy?

**NotesMy** è un'applicazione nativa per macOS che unisce la prontezza dei foglietti adesivi (*Unclutter*, *SideNotes*) con la ricchezza strutturale delle moderne basi di conoscenza (*Obsidian*, *Apple Notes*).

Scritta al 100% in **Swift 6, SwiftUI e AppKit**, NotesMy risiede silenziosamente nella barra dei menu ed entra in azione scivolando con naturalezza dal bordo dello schermo non appena avvicini il puntatore o premi una scorciatoia.

### ✨ Punti di Forza

- 🪟 **Cassetto Laterale (Edge Deck):** Avvicina il cursore al bordo dello schermo per mostrare le tue note attive in un ventaglio animato.
- 🔄 **Aggiornamenti Automatici Integrati:** Verifica diretta delle release GitHub nelle Impostazioni, note di rilascio, indicatore di avanzamento download DMG e aggiornamento in 1 clic.
- ⌨️ **Navigazione con Tasti Freccia:** Scorri agevolmente tra tag e categorie con le frecce (`←` / `→`) e pulsanti dedicati.
- 🗑️ **Eliminazione Rapida & Pulizia Note Inattive:** Rimuovi una nota con un tocco direttamente sulla scheda; rilevamento e archiviazione automatica delle note non modificate da oltre 30 giorni.
- ⚙️ **Chiusura Finestre Sicura:** Il pulsante rosso delle impostazioni non arresta l'applicazione; procedura di conferma a due passaggi prima di azzerare i dati.
- 🧠 **Grafo di Conoscenza IA con Fisica:** Simulazione Coulomb-Hooke, similarità concettuale Jaccard, collegamenti bidirezionali `[[WikiLinks]]` e linee continue colorate brillanti sui nodi selezionati.
- 🔍 **OCR su Schermo e Visione Artificiale:** Cattura qualsiasi area del monitor ed estrai istantaneamente il testo negli appunti o in una nota.
- 🎙️ **Note Vocali sul Dispositivo:** Trascrizione vocale istantanea in 12 lingue con latenza zero e massima riservatezza.
- 📌 **Bacheca Libera (Sticky Board):** Disponi le tue note come cartoncini colorati su un piano di sughero infinito, ingrandibile e trascinabile.
- 🎨 **Tavolozze Pastello Minimaliste:** 6 colori tenui coordinati con lo stile macOS, supporto markdown completo, liste di controllo ed evidenziazione del codice.
- 🛡️ **Nessuna Telemetria & 100% Offline:** Nessun server esterno, nessun account richiesto. Tutti i modelli di IA operano sul processore del tuo Mac.

---

## 🍺 Installazione tramite Homebrew

La modalità ideale per installare e aggiornare NotesMy su macOS:

```bash
# 1. Aggiungi il repository Homebrew
brew tap mehmetefeaytas/tap

# 2. Installa NotesMy
brew install --cask notesmy
```

### Aggiornamento
```bash
brew upgrade --cask notesmy
```

### Installazione Manuale (DMG)
Se desideri scaricare direttamente l'immagine disco Universal, visita la pagina [GitHub Releases](https://github.com/mehmetefeaytas/notesmy/releases/latest).

> **Avviso Gatekeeper (Primo Avvio):** Trattandosi di un software open-source indipendente, macOS potrebbe mostrare un avviso di sicurezza. Fai clic destro su `NotesMy.app` in `/Applications` e scegli **Apri**, oppure esegui nel Terminale:
> ```bash
> xattr -cr /Applications/NotesMy.app
> ```

---

## 📸 Immagini dell'Applicazione

<table width="100%">
  <tr>
    <td width="50%">
      <h3 align="center">🕸️ Grafo della Conoscenza IA & Connessioni Luminose</h3>
      <img src="../assets/preview-graph.png" alt="NotesMy Grafo della Conoscenza" width="100%" />
    </td>
  </tr>
</table>

---

## 💎 Riepilogo Funzionalità

| Categoria | Funzionalità | Stato | Tecnologia |
| :--- | :--- | :---: | :--- |
| **V1 — Base** | Note testuali e liste to-do con temi pastello | ✅ | SwiftUI TextEditor nativo |
| **V1 — Base** | Cassetto laterale fluttuante ancorato al bordo | ✅ | AppKit NSPanel flottante |
| **V1 — Base** | Tag, cartelle, appunti fissati e preferiti | ✅ | Archiviazione JSON locale |
| **V1 — Base** | Navigazione da tastiera (`←` / `→`) tra categorie | ✅ | AppKit Event Monitor + ScrollViewReader |
| **V1 — Base** | Eliminazione rapida direttamente dalla scheda | ✅ | Swift Action Handler |
| **V1 — Base** | Cronologia appunti con cattura automatica | ✅ | NSPasteboard Monitor |
| **V1 — Base** | Selettore colore interattivo e finestre ridimensionabili | ✅ | AppKit NSWindow + SwiftUI |
| **V2 — Potenziato** | Trascrizione vocale multilingue in 12 lingue | ✅ | Apple SFSpeechRecognizer |
| **V2 — Potenziato** | Estrazione testo OCR da selezione su schermo | ✅ | Apple Vision + screencapture |
| **V2 — Potenziato** | Bacheca libera interattiva (Sticky Board) | ✅ | Canvas SwiftUI con Drag & Drop |
| **V2 — Potenziato** | Archiviazione automatica note inattive (>30 giorni) | ✅ | Rilevatore temporale di inattività |
| **V2 — Potenziato** | Riconoscimento intelligente di date e promemoria | ✅ | NSDataDetector + UserNotifications |
| **V2 — Potenziato** | Ricerca vettoriale semantica basata su concetti | ✅ | Embeddings Apple NaturalLanguage |
| **V3 — Connesso** | Aggiornamenti integrati e controllo versioni GitHub | ✅ | GitHub REST API + URLSession |
| **V3 — Connesso** | Web Clipper per acquisizione e riassunto link | ✅ | WebKit + URLSession |
| **V3 — Connesso** | Esportazione eventi di calendario (.ics) in 1 clic | ✅ | Generatore standard RFC 5545 |
| **V3 — Connesso** | Esportazione verso Apple Note e Promemoria | ✅ | NSSharingService + EventKit |
| **V3 — Connesso** | Sincronizzazione privata CloudKit e backup locale | ✅ | Contenitore privato Apple CloudKit |
| **V3 — Connesso** | Cronologia delle revisioni con ripristino nel tempo | ✅ | Snapshot incrementali |
| **V4 — Secondo Cervello** | Grafo di conoscenza simulato con fisica Coulomb-Hooke | ✅ | Simulazione matematica + Canvas |
| **V4 — Secondo Cervello** | Linee continue e luminose sui nodi selezionati | ✅ | Tracciati vettoriali SwiftUI |
| **V4 — Secondo Cervello** | Collegamenti bidirezionali `[[WikiLinks]]` e backlinks | ✅ | Analizzatore regex di link |
| **V4 — Secondo Cervello** | Chat IA locale su tutto il corpus delle note | ✅ | Architettura RAG locale |
| **V4 — Secondo Cervello** | Generazione piano d'azione ed estrazione compiti | ✅ | Rilevatore NLP di task |
| **V4 — Secondo Cervello** | Riorganizzazione pensieri sparsi e formattazione | ✅ | Motore NLP Apple Intelligence |

---

## 🌍 Lingue Disponibili (12 Lingue)

NotesMy rileva la lingua impostata su macOS e offre traduzione completa e supporto vocale per:

| Bandiera | Lingua | Bandiera | Lingua | Bandiera | Lingua |
| :---: | :--- | :---: | :--- | :---: | :--- |
| 🇬🇧 | English | 🇹🇷 | Türkçe | 🇩🇪 | Deutsch |
| 🇫🇷 | Français | 🇪🇸 | Español | 🇧🇷 | Português (Brasile) |
| 🇮🇹 | Italiano | 🇷🇺 | Русский | 🇯🇵 | 日本語 |
| 🇰🇷 | 한국어 | 🇸🇦 | العربية (RTL) | 🇨🇳 | 简体中文 |

---

## ⌨️ Scorciatoie da Tastiera Globali

Puoi modificare qualsiasi scorciatoia in **Impostazioni → Scorciatoie**:

| Scorciatoia | Azione | Descrizione |
| :--- | :--- | :--- |
| `⌥⌘N` | **Nuova Nota** | Crea un nuovo foglietto fluttuante sullo schermo |
| `⌥⌘V` | **Acquisizione Rapida** | Incolla il contenuto degli appunti in una nota nuova |
| `⌥⌘L` | **Tutte le Note** | Apre la console di ricerca e catalogazione |
| `⌥⌘B` | **Bacheca** | Apre la bacheca in sughero interattiva |
| `⌥⌘A` | **Archivio** | Mostra l'elenco delle note archiviate |
| `⌃⌥⌘H` | **Mostra/Nascondi Cassetto**| Attiva o nasconde il cassetto laterale |
| `Esc` | **Chiudi Nota** | Chiude la finestra di modifica in primo piano |

---

## 📈 Storico delle Stelle

[![Star History Chart](https://api.star-history.com/svg?repos=mehmetefeaytas/notesmy&type=Date)](https://star-history.com/#mehmetefeaytas/notesmy&Date)

---

## 👥 Collaboratori

Contributi, idee per nuove funzionalità e segnalazioni di bug sono sempre ben accetti!

<a href="https://github.com/mehmetefeaytas/notesmy/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=mehmetefeaytas/notesmy" alt="Collaboratori" />
</a>

Consulta il documento [CONTRIBUTING.md](../CONTRIBUTING.md) per le linee guida di sviluppo e testing.

---

## 💖 Sponsor e Supporto

Se NotesMy rende il tuo lavoro sul Mac più agile e piacevole, sostieni il progetto:

<p align="center">
  <a href="https://github.com/sponsors/mehmetefeaytas"><img src="https://img.shields.io/badge/GitHub%20Sponsors-Supporta-EA4AAA?style=for-the-badge&logo=githubsponsors" alt="GitHub Sponsors" /></a>
</p>

---

## 📬 Contatti

Per qualsiasi informazione, richiesta o scambio di idee:

- 📧 **Email:** [efeyapiyor@gmail.com](mailto:efeyapiyor@gmail.com)
- 💼 **LinkedIn:** [Mehmet Efe Aytaş](https://linkedin.com/in/mehmetefeaytas)
- 🐙 **GitHub:** [@mehmetefeaytas](https://github.com/mehmetefeaytas)

---

## 🛡️ Riservatezza e Architettura

- **100% Locale e Offline:** Nessuna connessione verso server terzi, nessun tracciamento telemetrico.
- **File di Testo Trasparenti:** Le note sono salvate sul Mac in `~/Library/Application Support/NotesMy/notes.json`.
- **iCloud / CloudKit:** La sincronizzazione cloud opzionale transita solo nel tuo spazio privato iCloud.

---

## 📄 Licenza

NotesMy è rilasciato sotto licenza **Apache License 2.0**. Dettagli completi nel file [LICENSE](../LICENSE).

Creato con ❤️ da **[Mehmet Efe Aytaş](https://github.com/mehmetefeaytas)**.
