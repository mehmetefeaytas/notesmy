import os

languages = [
    {
        "code": "tr",
        "name": "Türkçe",
        "flag": "🇹🇷",
        "title": "NotesMy — macOS İçin Yapay Zeka Destekli İkinci Beyin & Akıllı Notlar",
        "tagline": "Ekran Kenarına Sabitlenen Sürtünmesiz Notlar, Bilgi Grafiği, Çok Dilli Sesli Notlar & Çevrimdışı Yapay Zeka",
        "install_title": "Homebrew ile Kurulum",
        "features_title": "Temel Özellikler",
        "matrix_title": "Sürüm & Özellik Matrisi",
        "shortcuts_title": "Global Klavye Kısayolları",
        "contributing_title": "Katkıda Bulunma & Sürüm Politikası",
        "contributing_desc": "Katkılar, hata bildirimleri ve özellik önerileri memnuniyetle karşılanır! Yeni sürüm yayınlama (Release) yetkisi yalnızca proje sahibine ([@mehmetefeaytas](https://github.com/mehmetefeaytas)) aittir. Ayrıntılı geliştirici kuralları için lütfen [CONTRIBUTING.md](../CONTRIBUTING.md) belgesini inceleyin."
    },
    {
        "code": "de",
        "name": "Deutsch",
        "flag": "🇩🇪",
        "title": "NotesMy — KI-gestütztes Second Brain & Haftnotizen für macOS",
        "tagline": "Reibungslose Haftnotizen am Bildschirmrand, Wissensgraph, mehrsprachige Sprachmemos & 100% On-Device-KI",
        "install_title": "Installation via Homebrew",
        "features_title": "Hauptfunktionen",
        "matrix_title": "Versions- und Funktionsmatrix",
        "shortcuts_title": "Globale Tastatur-Kurzbefehle",
        "contributing_title": "Mitwirken & Veröffentlichungsrichtlinie",
        "contributing_desc": "Beiträge, Fehlerberichte und Funktionsvorschläge sind willkommen! Das Veröffentlichen neuer Releases ist ausschließlich dem Maintainer ([@mehmetefeaytas](https://github.com/mehmetefeaytas)) vorbehalten. Bitte beachten Sie die Richtlinien in [CONTRIBUTING.md](../CONTRIBUTING.md)."
    },
    {
        "code": "fr",
        "name": "Français",
        "flag": "🇫🇷",
        "title": "NotesMy — Second Cerveau & Pense-bêtes propulsés par l'IA pour macOS",
        "tagline": "Notes adhésives sans friction sur le bord de l'écran, graphe de connaissances, transcription vocale & IA hors ligne",
        "install_title": "Installation via Homebrew",
        "features_title": "Fonctionnalités Principales",
        "matrix_title": "Matrice des Fonctionnalités",
        "shortcuts_title": "Raccourcis Clavier Globaux",
        "contributing_title": "Contribution & Politique de Publication",
        "contributing_desc": "Les contributions et rapports de bugs sont les bienvenus ! La publication de versions officielles est strictement réservée au mainteneur ([@mehmetefeaytas](https://github.com/mehmetefeaytas)). Consultez [CONTRIBUTING.md](../CONTRIBUTING.md)."
    },
    {
        "code": "es",
        "name": "Español",
        "flag": "🇪🇸",
        "title": "NotesMy — Segundo Cerebro y Notas Adhesivas con IA para macOS",
        "tagline": "Notas adhesivas en el borde de la pantalla, grafo de conocimiento, notas de voz multilingües e IA 100% local",
        "install_title": "Instalación con Homebrew",
        "features_title": "Características Principales",
        "matrix_title": "Matriz de Versiones y Características",
        "shortcuts_title": "Atajos de Teclado Globales",
        "contributing_title": "Contribuir y Política de Lanzamiento",
        "contributing_desc": "¡Las contribuciones son bienvenidas! El lanzamiento y publicación de nuevas versiones está estrictamente reservado al mantenedor principal ([@mehmetefeaytas](https://github.com/mehmetefeaytas)). Consulte [CONTRIBUTING.md](../CONTRIBUTING.md)."
    },
    {
        "code": "pt",
        "name": "Português",
        "flag": "🇧🇷",
        "title": "NotesMy — Segundo Cérebro e Notas Adesivas com IA para macOS",
        "tagline": "Notas rápidas na borda da tela, grafo de conhecimento, notas de voz com transcrição e IA 100% no dispositivo",
        "install_title": "Instalação via Homebrew",
        "features_title": "Recursos Principais",
        "matrix_title": "Matriz de Recursos e Versões",
        "shortcuts_title": "Atalhos de Teclado Globais",
        "contributing_title": "Contribuição e Política de Lançamento",
        "contributing_desc": "Contribuições são bem-vindas! O lançamento de versões oficiais é restrito exclusivamente ao mantenedor do projeto ([@mehmetefeaytas](https://github.com/mehmetefeaytas)). Veja [CONTRIBUTING.md](../CONTRIBUTING.md)."
    },
    {
        "code": "it",
        "name": "Italiano",
        "flag": "🇮🇹",
        "title": "NotesMy — Secondo Cervello e Note Adesive con IA per macOS",
        "tagline": "Note adesive sul bordo dello schermo senza attrito, grafo della conoscenza, memo vocali multilingue e IA privata",
        "install_title": "Installazione tramite Homebrew",
        "features_title": "Funzionalità Principali",
        "matrix_title": "Matrice delle Funzionalità",
        "shortcuts_title": "Scorciatoie da Tastiera Globali",
        "contributing_title": "Contributi e Politica di Rilascio",
        "contributing_desc": "Contributi e segnalazioni sono benvenuti! Il rilascio di nuove versioni è riservato esclusivamente al manutentore ([@mehmetefeaytas](https://github.com/mehmetefeaytas)). Consulta [CONTRIBUTING.md](../CONTRIBUTING.md)."
    },
    {
        "code": "ru",
        "name": "Русский",
        "flag": "🇷🇺",
        "title": "NotesMy — Второй Мозг и Заметки с ИИ для macOS",
        "tagline": "Умные заметки у края экрана, граф знаний, многоязычные голосовые заметки и локальный ИИ без интернета",
        "install_title": "Установка через Homebrew",
        "features_title": "Ключевые Возможности",
        "matrix_title": "Матрица Версий и Функций",
        "shortcuts_title": "Глобальные Горячие Клавиши",
        "contributing_title": "Участие в разработке и политика релизов",
        "contributing_desc": "Приветствуются улучшения и сообщения об ошибках! Публикация официальных релизов доступна исключительно мейнтейнеру ([@mehmetefeaytas](https://github.com/mehmetefeaytas)). Подробнее в [CONTRIBUTING.md](../CONTRIBUTING.md)."
    },
    {
        "code": "ja",
        "name": "日本語",
        "flag": "🇯🇵",
        "title": "NotesMy — macOS向け AI搭載セカンドブレイン＆付箋ノート",
        "tagline": "画面端に吸着するシームレス付箋、ナレッジグラフ、多言語音声文字起こし、完全オンデバイスAI",
        "install_title": "Homebrewでのインストール",
        "features_title": "主な機能",
        "matrix_title": "機能マトリックス",
        "shortcuts_title": "グローバルキーボードショートカット",
        "contributing_title": "コントリビューションとリリース権限",
        "contributing_desc": "バグ報告やプルリクエストを歓迎します！公式リリースの発行はプロジェクトメンテナー（[@mehmetefeaytas](https://github.com/mehmetefeaytas)）限定です。詳細は [CONTRIBUTING.md](../CONTRIBUTING.md) をご覧ください。"
    },
    {
        "code": "ko",
        "name": "한국어",
        "flag": "🇰🇷",
        "title": "NotesMy — macOS를 위한 AI 세컨드 브레인 & 스마트 메모",
        "tagline": "화면 가장자리 도킹 스티커 메모, 지식 그래프, 다국어 음성 실시간 텍스트 변환 및 100% 온디바이스 AI",
        "install_title": "Homebrew로 설치하기",
        "features_title": "주요 기능",
        "matrix_title": "버전 및 기능 매트릭스",
        "shortcuts_title": "글로벌 단축키",
        "contributing_title": "기여 및 릴리스 정책",
        "contributing_desc": "버그 제보와 기여는 언제나 환영합니다! 공식 릴리스 발행은 프로젝트 관리자([@mehmetefeaytas](https://github.com/mehmetefeaytas))로 엄격히 제한됩니다. 자세한 내용은 [CONTRIBUTING.md](../CONTRIBUTING.md)를 확인하세요."
    },
    {
        "code": "ar",
        "name": "العربية",
        "flag": "🇸🇦",
        "title": "NotesMy — العقل الثاني والملاحظات اللاصقة المدعومة بالذكاء الاصطناعي لنظام macOS",
        "tagline": "ملاحظات فورية على حافة الشاشة، رسم بياني للمعرفة، تفريغ صوتي متعدد اللغات وخصوصية تامة بدون إنترنت",
        "install_title": "التثبيت عبر Homebrew",
        "features_title": "الميزات الرئيسية",
        "matrix_title": "مصفوفة الميزات والإصدارات",
        "shortcuts_title": "اختصارات لوحة المفاتيح العامة",
        "contributing_title": "المساهمة وسياسة النشر",
        "contributing_desc": "المساهمات مرحب بها دائماً! نشر الإصدارات الرسمية يقتصر بشكل صارم على المشرف الرئيسي ([@mehmetefeaytas](https://github.com/mehmetefeaytas)). راجع [CONTRIBUTING.md](../CONTRIBUTING.md)."
    },
    {
        "code": "zh",
        "name": "中文",
        "flag": "🇨🇳",
        "title": "NotesMy — 面向 macOS 的 AI 第二大脑与智能便签",
        "tagline": "屏幕边缘贴边悬浮便签、双向知识图谱、多语言语音实时转文字与 100% 本地端侧 AI",
        "install_title": "通过 Homebrew 安装",
        "features_title": "核心特性",
        "matrix_title": "版本与功能矩阵",
        "shortcuts_title": "全局键盘快捷键",
        "contributing_title": "贡献指南与发布策略",
        "contributing_desc": "欢迎提交 Bug 反馈与改进建议！新版本的正式发布与 Homebrew Cask 更新严格限定为维护者（[@mehmetefeaytas](https://github.com/mehmetefeaytas)）执行。详见 [CONTRIBUTING.md](../CONTRIBUTING.md)。"
    }
]

lang_switcher = (
    "[🇬🇧 English](../README.md) · "
    "[🇹🇷 Türkçe](README_tr.md) · "
    "[🇩🇪 Deutsch](README_de.md) · "
    "[🇫🇷 Français](README_fr.md) · "
    "[🇪🇸 Español](README_es.md) · "
    "[🇧🇷 Português](README_pt.md) · "
    "[🇮🇹 Italiano](README_it.md) · "
    "[🇷🇺 Русский](README_ru.md) · "
    "[🇯🇵 日本語](README_ja.md) · "
    "[🇰🇷 한국어](README_ko.md) · "
    "[🇸🇦 العربية](README_ar.md) · "
    "[🇨🇳 中文](README_zh.md)"
)

os.makedirs("docs", exist_ok=True)

for lang in languages:
    content = f"""# {lang['flag']} {lang['title']}

<p align="center">
  {lang_switcher}
</p>

<p align="center">
  <img src="../assets/hero_banner.jpg" alt="NotesMy Hero Banner" width="100%" />
</p>

<p align="center">
  <strong>{lang['tagline']}</strong>
</p>

<p align="center">
  <a href="https://github.com/mehmetefeaytas/notesmy/releases"><img src="https://img.shields.io/github/v/release/mehmetefeaytas/notesmy?style=flat-square&color=8B5CF6" alt="Release" /></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?style=flat-square&logo=apple" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=flat-square&logo=swift" alt="Swift 6" />
  <img src="https://img.shields.io/badge/Arch-Universal%20(ARM64%20%2B%20x86__64)-green?style=flat-square" alt="Universal" />
  <img src="https://img.shields.io/badge/License-Apache%202.0-yellow?style=flat-square" alt="License" />
  <img src="https://img.shields.io/badge/Privacy-100%25%20On--Device-success?style=flat-square" alt="Privacy" />
</p>

---

## 🍺 {lang['install_title']}

```bash
# Tap the repository
brew tap mehmetefeaytas/tap

# Install NotesMy
brew install --cask notesmy
```

### Direct Download (.dmg)
You can also download the precompiled **Universal DMG** directly from [GitHub Releases](https://github.com/mehmetefeaytas/notesmy/releases/latest).

---

## ✨ {lang['features_title']}

<table width="100%">
  <tr>
    <td width="50%"><img src="../assets/feature_notes.jpg" alt="Notes" width="100%" /></td>
    <td width="50%"><img src="../assets/feature_ai.jpg" alt="AI Second Brain" width="100%" /></td>
  </tr>
  <tr>
    <td width="50%"><img src="../assets/feature_voice.jpg" alt="Voice Transcription" width="100%" /></td>
    <td width="50%"><img src="../assets/feature_board.jpg" alt="Sticky Board" width="100%" /></td>
  </tr>
</table>

- **🪟 Edge-Docked Deck (Unclutter & SideNotes Inspired):** Hover over the screen edge to reveal notes instantly.
- **🧠 AI Second Brain & Knowledge Graph:** Interactive node graph visualizing bidirectional `[[WikiLinks]]` connections.
- **🎙️ Multilingual Voice Notes:** Real-time speech transcription with 12 language support via `SFSpeechRecognizer`.
- **📸 Screenshot Capture & Vision OCR:** Take interactive screen captures and extract text using Apple Vision.
- **📅 Calendar Integration:** One-click `.ics` export with Apple Calendar, Google Calendar, and Outlook support.
- **🔒 100% On-Device & Zero Telemetry:** No cloud accounts required, no trackers, strict local JSON storage.

---

## ⌨️ {lang['shortcuts_title']}

| Shortcut | Action |
| :--- | :--- |
| `⌥⌘N` | New Sticky Note |
| `⌥⌘V` | Quick Capture from Clipboard |
| `⌥⌘L` | All Notes & Semantic Search |
| `⌥⌘B` | Open Sticky Board Canvas |
| `⌥⌘A` | Open Archive |
| `⌃⌥⌘H` | Toggle Edge Deck Visibility |
| `⌘[` / `⌘]` | Navigate Previous / Next Note |
| `Esc` | Close Active Note Window |

---

## 🤝 {lang['contributing_title']}

{lang['contributing_desc']}

---

## 📄 License

NotesMy is licensed under the **Apache License 2.0**.
"""
    with open(f"docs/README_{lang['code']}.md", "w", encoding="utf-8") as f:
        f.write(content.strip() + "\n")

print("✅ Generated all 11 localized README documents in docs/")
