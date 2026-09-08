# 🇫🇷 NotesMy — Second Cerveau IA & Pense-bêtes pour macOS

<p align="center">
  <img src="../assets/app_icon_1024.png" alt="NotesMy App Icon" width="128" height="128" style="border-radius: 28px; box-shadow: 0 8px 24px rgba(0,0,0,0.25);" />
</p>

<h2 align="center">Pense-bêtes fluides ancrés au bord de l'écran & Gestion des connaissances pour macOS</h2>

<p align="center">
  <a href="../README.md">🇬🇧 English</a> · 
  <a href="README_tr.md">🇹🇷 Türkçe</a> · 
  <a href="README_de.md">🇩🇪 Deutsch</a> · 
  <strong>[🇫🇷 Français](README_fr.md)</strong> · 
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
  <a href="https://github.com/mehmetefeaytas/homebrew-tap"><img src="https://img.shields.io/badge/Homebrew-Cask%20Disponible-orange?style=for-the-badge&logo=homebrew" alt="Homebrew" /></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?style=for-the-badge&logo=apple" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift" alt="Swift 6" />
  <img src="https://img.shields.io/badge/Architecture-Universelle%20(ARM64%20%2B%20x86__64)-green?style=for-the-badge" alt="Binaire Universel" />
  <img src="https://img.shields.io/badge/Confidentialit%C3%A9-100%25%20Sur--Appareil-success?style=for-the-badge" alt="Confidentialité" />
  <img src="https://img.shields.io/badge/Licence-Apache%202.0-yellow?style=for-the-badge" alt="Apache 2.0" />
</p>

---

## 🎬 Démo Cinématographique

<p align="center">
  <img src="../assets/demo.gif" alt="NotesMy Démo en direct" width="100%" style="border-radius: 12px; box-shadow: 0 12px 36px rgba(0,0,0,0.25);" />
</p>
<p align="center">
  <em>Enregistrement d'écran haute définition montrant le glissement fluide depuis le bord de l'écran, la capture rapide de notes, le tableau de liège interactif et la reconnaissance OCR instantanée. (<a href="../assets/demo.mp4">Télécharger MP4 60fps</a>)</em>
</p>

---

## ⚡ Qu'est-ce que NotesMy ?

**NotesMy** est une application native macOS ultra-rapide combinant des notes adhésives instantanées et la gestion des connaissances personnelles. Elle fait le lien entre la prise de notes immédiate (*Unclutter*, *SideNotes*) et les bases de connaissances structurées (*Obsidian*, *Apple Notes*).

Conçue à 100 % en **Swift 6, SwiftUI et AppKit**, NotesMy réside discrètement dans votre barre des menus et glisse avec élégance depuis le bord de votre écran à la moindre sollicitation.

### ✨ Fonctionnalités Clés

- 🪟 **Tiroir Latéral (Edge Deck) :** Survolez le bord de l'écran pour déployer un éventail animé de toutes vos notes actives.
- 🔄 **Mises à Jour Automatiques Intégrées :** Vérification directe des versions GitHub dans les Réglages, journal des modifications, jauge de téléchargement DMG et mise à jour en 1 clic.
- ⌨️ **Navigation Clavier des Catégories :** Faites défiler horizontalement vos catégories et filtres à l'aide des touches fléchées (`←` / `→`) ou des boutons latéraux.
- 🗑️ **Suppression Rapide & Nettoyage des Notes Inactives :** Suppression en un clic directement sur la carte de note ; détection et archivage automatique des notes délaissées depuis plus de 30 jours.
- ⚙️ **Gestion Sécurisée des Fenêtres :** Le bouton rouge des réglages ne quitte jamais l'application ; confirmation en 2 étapes avant toute réinitialisation des données.
- 🧠 **Graphe de Connaissances IA Mathématique :** Simulation physique Coulomb-Hooke, similarité de concepts Jaccard, `[[WikiLinks]]` bidirectionnels et lignes pleines colorées éclatantes lors de la sélection d'un nœud.
- 🔍 **OCR Visuel & Reconnaissance de Texte :** Sélectionnez une zone de l'écran pour en extraire instantanément le texte via Apple Vision.
- 🎙️ **Notes Vocales Locales :** Retranscription instantanée de la parole dans 12 langues, sans latence et dans le respect total de votre vie privée.
- 📌 **Tableau de Notes Libre (Sticky Board) :** Disposez vos notes sous forme de fiches colorées sur un tableau infini, zoomable et repositionnable.
- 🎨 **Palettes Pastel Minimalistes :** 6 teintes pastel calibrées pour macOS, formatage markdown riche, listes de tâches et coloration de code.
- 🛡️ **Zéro Télémétrie & 100 % Hors-ligne :** Aucune collecte de données, aucun compte requis. Tous les modèles d'IA s'exécutent localement sur votre Mac.

---

## 🍺 Installation via Homebrew

La méthode recommandée pour installer et maintenir à jour NotesMy sur macOS :

```bash
# 1. Ajouter le dépôt Homebrew
brew tap mehmetefeaytas/tap

# 2. Installer NotesMy
brew install --cask notesmy
```

### Mettre à jour
```bash
brew upgrade --cask notesmy
```

### Téléchargement Manuel (DMG)
Vous préférez télécharger directement le fichier DMG Universel ? Obtenez la dernière version sur la page [GitHub Releases](https://github.com/mehmetefeaytas/notesmy/releases/latest).

> **Avis Gatekeeper (Premier lancement) :** NotesMy étant distribué en open-source sans certificat d'entreprise payant, macOS peut afficher une alerte de sécurité. Faites un clic droit sur `NotesMy.app` dans `/Applications` puis sélectionnez **Ouvrir**, ou exécutez dans le Terminal :
> ```bash
> xattr -cr /Applications/NotesMy.app
> ```

---

## 📸 Aperçu de l'Application

<table width="100%">
  <tr>
    <td width="50%">
      <h3 align="center">🗂️ Toutes les Notes & Recherche Sémantique</h3>
      <img src="../assets/preview-allnotes.png" alt="Fenêtre principale NotesMy" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🪟 Tiroir Latéral au Bord de l'Écran</h3>
      <img src="../assets/preview-edge-deck.png" alt="NotesMy Edge Deck" width="100%" />
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3 align="center">📝 Éditeur de Notes Minimaliste</h3>
      <img src="../assets/preview-note.png" alt="Éditeur de note NotesMy" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🎨 Icône Moderne Pastel</h3>
      <img src="../assets/app_icon_1024.png" alt="Icône NotesMy" width="60%" style="display: block; margin: 0 auto;" />
    </td>
  </tr>
</table>

---

## 💎 Matrice Complète des Fonctionnalités

| Niveau | Fonctionnalité | État | Technologie |
| :--- | :--- | :---: | :--- |
| **V1 — Essentiel** | Prise de notes texte et listes à cocher avec thèmes pastel | ✅ | SwiftUI TextEditor natif |
| **V1 — Essentiel** | Tiroir latéral en éventail ancré à l'écran | ✅ | AppKit NSPanel flottant |
| **V1 — Essentiel** | Étiquettes, catégories, épingles et favoris | ✅ | Stockage JSON local |
| **V1 — Essentiel** | Navigation clavier (`←` / `→`) entre catégories | ✅ | AppKit Event Monitor + ScrollViewReader |
| **V1 — Essentiel** | Suppression rapide directement sur la carte de note | ✅ | Gestionnaire d'actions Swift |
| **V1 — Essentiel** | Historique du presse-papiers avec capture auto | ✅ | NSPasteboard Monitor |
| **V1 — Essentiel** | Sélecteur de couleur interactif et fenêtres redimensionnables | ✅ | AppKit NSWindow + SwiftUI |
| **V2 — Avancé** | Notes vocales multilingues (Dictée en texte) | ✅ | Apple SFSpeechRecognizer |
| **V2 — Avancé** | Extraction de texte OCR par capture d'écran | ✅ | Apple Vision + screencapture |
| **V2 — Avancé** | Tableau libre interactif (Corkboard) | ✅ | Canvas SwiftUI Glisser-Déposer |
| **V2 — Avancé** | Archivage automatique des notes inactives (>30 jours) | ✅ | Moteur d'obsolescence |
| **V2 — Avancé** | Détection automatique des dates et rappels | ✅ | NSDataDetector + UserNotifications |
| **V2 — Avancé** | Recherche vectorielle conceptuelle et sémantique | ✅ | Apple NaturalLanguage Embeddings |
| **V3 — Connecté** | Mises à jour auto intégrées & vérification GitHub | ✅ | GitHub REST API + URLSession |
| **V3 — Connecté** | Web Clipper d'URL avec extraction de contenu | ✅ | WebKit + URLSession |
| **V3 — Connecté** | Export calendrier en un clic (.ics) | ✅ | Générateur RFC 5545 |
| **V3 — Connecté** | Export vers Apple Notes & Rappels | ✅ | NSSharingService + EventKit |
| **V3 — Connecté** | Synchronisation privée CloudKit et sauvegarde locale | ✅ | Conteneur Apple CloudKit |
| **V3 — Connecté** | Historique des versions et restauration temporelle | ✅ | Snapshots incrémentaux |
| **V4 — Second Cerveau** | Graphe de connaissances physique Coulomb-Hooke | ✅ | Simulation mathématique + Canvas |
| **V4 — Second Cerveau** | Connexions en lignes pleines colorées et lumineuses | ✅ | Tracés vectoriels SwiftUI |
| **V4 — Second Cerveau** | `[[WikiLinks]]` bidirectionnels avec index de rétro-liens | ✅ | Analyseur d'expressions régulières |
| **V4 — Second Cerveau** | Chat IA local sur l'ensemble de vos notes | ✅ | Architecture RAG locale NaturalLanguage |
| **V4 — Second Cerveau** | Extraction intelligente de plan d'action quotidien | ✅ | Extraction NLP de tâches |
| **V4 — Second Cerveau** | Nettoyage des pensées éparses & mise en forme auto | ✅ | Moteur NLP Apple Intelligence |

---

## 🌍 Langues Prises en Charge (12 Langues)

NotesMy s'adapte automatiquement à la langue de votre système macOS et propose une interface complète et une dictée vocale dans :

| Drapeau | Langue | Drapeau | Langue | Drapeau | Langue |
| :---: | :--- | :---: | :--- | :---: | :--- |
| 🇬🇧 | English | 🇹🇷 | Türkçe | 🇩🇪 | Deutsch |
| 🇫🇷 | Français | 🇪🇸 | Español | 🇧🇷 | Português (Brésil) |
| 🇮🇹 | Italiano | 🇷🇺 | Русский | 🇯🇵 | 日本語 |
| 🇰🇷 | 한국어 | 🇸🇦 | العربية (RTL) | 🇨🇳 | 简体中文 |

---

## ⌨️ Raccourcis Clavier Globaux

Tous les raccourcis sont personnalisables depuis **Réglages → Raccourcis** :

| Raccourci par défaut | Action | Description |
| :--- | :--- | :--- |
| `⌥⌘N` | **Nouvelle Note** | Ouvre instantanément une note adhésive à l'écran |
| `⌥⌘V` | **Capture Rapide** | Transforme le contenu du presse-papiers en note |
| `⌥⌘L` | **Toutes les Notes** | Ouvre la console principale avec recherche sémantique |
| `⌥⌘B` | **Tableau de Notes** | Ouvre le tableau de liège interactif |
| `⌥⌘A` | **Archives** | Affiche les notes archivées |
| `⌃⌥⌘H` | **Afficher/Masquer Tiroir** | Active ou désactive le dock au bord de l'écran |
| `Esc` | **Fermer la Note** | Ferme la fenêtre d'édition active |

---

## 📈 Historique des Étoiles

[![Star History Chart](https://api.star-history.com/svg?repos=mehmetefeaytas/notesmy&type=Date)](https://star-history.com/#mehmetefeaytas/notesmy&Date)

---

## 👥 Contributeurs

Les contributions, idées et rapports de bugs sont accueillis chaleureusement !

<a href="https://github.com/mehmetefeaytas/notesmy/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=mehmetefeaytas/notesmy" alt="Contributeurs" />
</a>

Consultez le guide [CONTRIBUTING.md](../CONTRIBUTING.md) pour les consignes et les tests.

---

## 💖 Sponsors & Soutien

Si NotesMy simplifie votre quotidien sur Mac, vous pouvez soutenir le projet :

<p align="center">
  <a href="https://github.com/sponsors/mehmetefeaytas"><img src="https://img.shields.io/badge/GitHub%20Sponsors-Soutenir-EA4AAA?style=for-the-badge&logo=githubsponsors" alt="GitHub Sponsors" /></a>
</p>

---

## 📬 Contact & Réseaux

Pour toute question ou opportunité d'échange :

- 📧 **E-mail :** [efeyapiyor@gmail.com](mailto:efeyapiyor@gmail.com)
- 💼 **LinkedIn :** [Mehmet Efe Aytaş](https://linkedin.com/in/mehmetefeaytas)
- 🐙 **GitHub :** [@mehmetefeaytas](https://github.com/mehmetefeaytas)

---

## 🛡️ Confidentialité & Architecture

- **100 % Hors-ligne :** NotesMy fonctionne sans le moindre serveur distant. Zéro télémétrie, zéro pistage.
- **Fichiers Locaux :** Les données sont enregistrées en clair dans `~/Library/Application Support/NotesMy/notes.json`.
- **iCloud / CloudKit :** La synchronisation optionnelle s'effectue strictement dans votre conteneur privé Apple iCloud.

---

## 📄 Licence

NotesMy est distribué sous licence **Apache License 2.0**. Consultez le fichier [LICENSE](../LICENSE) pour plus de détails.

Développé avec ❤️ par **[Mehmet Efe Aytaş](https://github.com/mehmetefeaytas)**.
