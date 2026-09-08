# 🇹🇷 NotesMy — macOS İçin Yapay Zeka Destekli İkinci Beyin & Akıllı Notlar

<p align="center">
  <img src="../assets/app_icon_1024.png" alt="NotesMy App Icon" width="128" height="128" style="border-radius: 28px; box-shadow: 0 8px 24px rgba(0,0,0,0.25);" />
</p>

<h2 align="center">macOS İçin Ekran Kenarına Sabitlenen Sürtünmesiz Notlar ve İkinci Beyin</h2>

<p align="center">
  <a href="../README.md">🇬🇧 English</a> · 
  <strong>[🇹🇷 Türkçe](README_tr.md)</strong> · 
  <a href="README_de.md">🇩🇪 Deutsch</a> · 
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
  <a href="https://github.com/mehmetefeaytas/homebrew-tap"><img src="https://img.shields.io/badge/Homebrew-Cask%20Mevcut-orange?style=for-the-badge&logo=homebrew" alt="Homebrew" /></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?style=for-the-badge&logo=apple" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift" alt="Swift 6" />
  <img src="https://img.shields.io/badge/Mimari-Universal%20(ARM64%20%2B%20x86__64)-green?style=for-the-badge" alt="Universal" />
  <img src="https://img.shields.io/badge/Gizlilik-%25100%20Cihaz%20%C3%9Czerinde-success?style=for-the-badge" alt="Gizlilik" />
  <img src="https://img.shields.io/badge/Lisans-Apache%202.0-yellow?style=for-the-badge" alt="Lisans" />
</p>

---

## 🎬 Sinematik Canlı Demo

<p align="center">
  <img src="../assets/demo.gif" alt="NotesMy Canlı Demo" width="100%" style="border-radius: 12px; box-shadow: 0 12px 36px rgba(0,0,0,0.25);" />
</p>
<p align="center">
  <em>NotesMy'ın ekran kenarından yumuşakça kayarak açılışı, hızlı not yakalama, pano yönetimi ve anlık OCR kullanımını gösteren ekran kaydı. (<a href="../assets/demo.mp4">60fps MP4 İndir</a>)</em>
</p>

---

## ⚡ NotesMy Nedir?

**NotesMy**, ekran kenarından anında açılan yapışkan notların (SideNotes, Unclutter) hızı ile modern kişisel bilgi yönetim sistemlerinin (Obsidian, Apple Intelligence) derinliğini bir araya getiren açık kaynaklı bir macOS uygulamasıdır.

Tamamen yerel **Swift 6, SwiftUI ve AppKit** ile geliştirilen NotesMy, menü çubuğunuzda sessizce yer alır ve ekranın kenarına fareyle geldiğinizde veya kısayola bastığınızda sürtünmesizce kayarak açılır.

### ✨ Öne Çıkan Yetenekler

- 🪟 **Ekran Kenarı Çekmecesi:** Ekranın sağına/soluna yanaştığınızda yelpaze şeklinde açılan canlı not kartları.
- 🔄 **Uygulama İçi Otomatik Güncelleme:** Ayarlar içerisinden doğrudan GitHub Releases sürüm kontrolü, değişiklik günlüğü (changelog), DMG indirme ilerleme çubuğu ve tek tıkla güncelleme.
- ⌨️ **Klavye Ok Tuşlarıyla Kategori Gezintisi:** Sol/sağ ok tuşlarıyla (`←` / `→`) veya tıklanabilir butonlarla kategoriler ve filtreler arasında pürüzsüz yatay geçiş.
- 🗑️ **Hızlı Not Silme & Kullanılmayan Notları Temizleme:** Not kartı üzerinden tek tıkla hızlı silme; 30 günden uzun süredir dokunulmayan eski notları otomatik tespit edip toplu arşivleme/silme teklifi.
- 🛡️ **Güvenli Pencere Yönetimi:** Ayarlar penceresi kapatıldığında uygulamanın kapanmaması güvencesi ve kazara veri kaybını önleyen 2 aşamalı onaylı not sıfırlama sistemi.
- 🧠 **Matematiksel & Yapay Zeka Destekli Bağlantı Ağı:** Coulomb-Hooke fizik simülasyonu, Jaccard kavram benzerliği, çift yönlü `[[WikiLinks]]` ve seçilen notta parlayan canlı renkli düz bağlantı çizgileri.
- 🔍 **Ekrandan Metin Yakalama (OCR):** Ekranın dilediğiniz bir bölgesini seçerek görüntüdeki yazıları Apple Vision ile anında kopyalama.
- 🎙️ **Çok Dilli Sesli Notlar:** Apple Silicon NPU hızlandırmalı, 12 dilde anlık ses transkripti.
- 📌 **Mantar Pano (Sticky Board):** Serbestçe sürüklenebilen ve yakınlaştırılabilen yapışkan not tuvali.
- 🎨 **Minimalist Pastel Temalar:** Gözü yormayan 6 pastel ton, markdown biçimlendirme ve kod modu.
- 🔒 **Sıfır Telemetri & %100 Çevrimdışı:** İnternet bağlantısı gerektirmez, tüm veriler Mac'inizde yerel olarak saklanır.

---

## 🍺 Homebrew ile Kurulum

macOS üzerinde kurmanın ve güncel kalmanın en kolay yolu:

```bash
# 1. Depoyu ekleyin (Tap)
brew tap mehmetefeaytas/tap

# 2. NotesMy'ı yükleyin
brew install --cask notesmy
```

### Güncelleme
```bash
brew upgrade --cask notesmy
```

### Manuel DMG İndirme
Doğrudan Universal DMG dosyasını indirmek isterseniz [GitHub Releases](https://github.com/mehmetefeaytas/notesmy/releases/latest) sayfasından en güncel sürümü edinebilirsiniz.

> **İlk Açılış İpucu (Gatekeeper):** NotesMy bağımsız geliştirildiği için macOS ilk açılışta geliştirici uyarısı gösterebilir. Uygulamalar klasöründeki `NotesMy.app` simgesine sağ tıklayıp **Aç** diyebilir ya da Terminal'de şunu çalıştırabilirsiniz:
> ```bash
> xattr -cr /Applications/NotesMy.app
> ```

---

## 📸 Gerçek Uygulama Arayüzü

<table width="100%">
  <tr>
    <td width="50%">
      <h3 align="center">🗂️ Tüm Notlar & Anlamsal Arama</h3>
      <img src="../assets/preview-allnotes.png" alt="Tüm Notlar Penceresi" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🪟 Ekran Kenarı Çekmecesi</h3>
      <img src="../assets/preview-edge-deck.png" alt="Ekran Kenarı Çekmecesi" width="100%" />
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3 align="center">📝 Minimalist Not Düzenleyici</h3>
      <img src="../assets/preview-note.png" alt="Not Düzenleyici" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🎨 Modern Pastel İkon</h3>
      <img src="../assets/app_icon_1024.png" alt="NotesMy İkonu" width="60%" style="display: block; margin: 0 auto;" />
    </td>
  </tr>
</table>

---

## 💎 Kapsamlı Özellik Tablosu

| Aşama | Özellik | Durum | Teknoloji |
| :--- | :--- | :---: | :--- |
| **V1 — Temel** | Pastel temalı metin ve kontrol listesi (checklist) notları | ✅ | Yerel SwiftUI TextEditor |
| **V1 — Temel** | Ekran kenarına sabitlenen yelpaze kart çekmecesi | ✅ | AppKit Yüzen NSPanel |
| **V1 — Temel** | Etiketler, Kategoriler, Sabitleme ve Favoriler | ✅ | Yerel JSON Depolama |
| **V1 — Temel** | Klavye Ok Tuşlarıyla (`←` / `→`) Kategoriler Arası Gezinme | ✅ | AppKit Event Monitor + ScrollViewReader |
| **V1 — Temel** | Not Kartı Üzerinden Anında Hızlı Silme | ✅ | Swift Action Handler |
| **V1 — Temel** | Pano Geçmişi Merkezi (Otomatik Metin Yakalama) | ✅ | NSPasteboard Monitor |
| **V1 — Temel** | İnteraktif Renk Seçici ve Boyutlandırılabilir Pencereler | ✅ | AppKit NSWindow + SwiftUI |
| **V2 — Gelişmiş** | 12 Dilde Sesli Notlar (Anlık Yazıya Dökme) | ✅ | Apple SFSpeechRecognizer |
| **V2 — Gelişmiş** | Ekran Kırpma ile Anında Metin Okuma (Vision OCR) | ✅ | Apple Vision + screencapture |
| **V2 — Gelişmiş** | İnteraktif Serbest Mantar Pano Tuvali | ✅ | SwiftUI Sürükle & Bırak Canvas |
| **V2 — Gelişmiş** | 30 Günden Eski Notları Otomatik Temizleme & Arşivleme | ✅ | Akıllı Zaman Aşımı Motoru |
| **V2 — Gelişmiş** | Doğal Dil Akıllı Tarih & Hatırlatıcı Bildirimleri | ✅ | NSDataDetector + UserNotifications |
| **V2 — Gelişmiş** | Anlamsal Vektör Araması (Semantic Search) | ✅ | Apple NaturalLanguage Gömümleri |
| **V3 — Entegre** | Uygulama İçi Otomatik Güncelleme & GitHub Sürüm Kontrolü | ✅ | GitHub REST API + URLSession |
| **V3 — Entegre** | Web Kırpıcı (Web Clipper) ile URL Özeti Çıkarma | ✅ | WebKit + URLSession |
| **V3 — Entegre** | Tek Tıkla Takvim Entegrasyonu (.ics) | ✅ | RFC 5545 Takvim Üretici |
| **V3 — Entegre** | Apple Notlar ve Anımsatıcılara Dışa Aktarma | ✅ | NSSharingService + EventKit |
| **V3 — Entegre** | Özel CloudKit Veritabanı Eşitleme & Yerel Yedekleme | ✅ | Apple CloudKit Kapsayıcısı |
| **V3 — Entegre** | Not Sürüm Geçmişi & Zamanda Geriye Dönüş (Restore) | ✅ | Artımlı Anlık Görüntüler |
| **V4 — İkinci Beyin** | Fizik Tabanlı Coulomb-Hooke Yapay Zeka Bilgi Ağı | ✅ | Matematiksel Fizik + Canvas |
| **V4 — İkinci Beyin** | Seçilen Notta Canlı Renkli Parlayan Düz Bağlantılar | ✅ | SwiftUI Vektör Grafik Çizimi |
| **V4 — İkinci Beyin** | Çift Yönlü `[[WikiLinks]]` ve Geri Bağlantı Dizini | ✅ | Regex Bağlantı Ayrıştırıcı |
| **V4 — İkinci Beyin** | Notlarınızla Doğal Dilde Yapay Zeka Sohbeti | ✅ | Cihaz İçi Yerel RAG Mimarisi |
| **V4 — İkinci Beyin** | Günlük Eylem Planı ve Görev Çıkarıcı | ✅ | Doğal Dil Görev Çıkarımı |
| **V4 — İkinci Beyin** | Dağınık Düşünceleri Temizleme & Otomatik Biçimlendirme | ✅ | Apple Intelligence NLP Motoru |

---

## 🌍 Desteklenen Diller (12 Dil)

NotesMy sistem dilinizi otomatik algılar ve aşağıdaki dillerde tam arayüz çevirisi ve ses transkripsiyonu sunar:

| Bayrak | Dil | Bayrak | Dil | Bayrak | Dil |
| :---: | :--- | :---: | :--- | :---: | :--- |
| 🇬🇧 | English | 🇹🇷 | Türkçe | 🇩🇪 | Deutsch |
| 🇫🇷 | Français | 🇪🇸 | Español | 🇧🇷 | Português (Brasil) |
| 🇮🇹 | Italiano | 🇷🇺 | Русский | 🇯🇵 | 日本語 |
| 🇰🇷 | 한국어 | 🇸🇦 | العربية (RTL) | 🇨🇳 | 简体中文 |

---

## ⌨️ Temel Kısayollar

Tüm kısayolları **Ayarlar → Kısayollar** sekmesinden kendi tercihinize göre kaydedebilirsiniz:

| Kısayol | İşlem | Açıklama |
| :--- | :--- | :--- |
| `⌥⌘N` | **Yeni Not** | Ekranda anında bağımsız bir yapışkan not açar |
| `⌥⌘V` | **Hızlı Yakalama** | Panodaki metni veya bağlantıyı anında nota dönüştürür |
| `⌥⌘L` | **Tüm Notlar & Arama** | Ana arama ve yönetim konsolunu açar |
| `⌥⌘B` | **Mantar Pano** | 2D serbest not tuvalini açar |
| `⌥⌘A` | **Arşiv** | Arşivlenmiş notları listeler |
| `⌃⌥⌘H` | **Çekmeceyi Göster/Gizle** | Kenar çekmecesini açıp kapatır |
| `Esc` | **Notu Kapat** | Aktif düzenleyici penceresini kapatır |

---

## 📈 Star Geçmişi

[![Star History Chart](https://api.star-history.com/svg?repos=mehmetefeaytas/notesmy&type=Date)](https://star-history.com/#mehmetefeaytas/notesmy&Date)

---

## 👥 Katkıda Bulunanlar

NotesMy topluluğuna katkı sağlayan herkese sonsuz teşekkürler!

<a href="https://github.com/mehmetefeaytas/notesmy/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=mehmetefeaytas/notesmy" alt="Katkıda Bulunanlar" />
</a>

Katkı kuralları ve test adımları için [CONTRIBUTING.md](../CONTRIBUTING.md) dosyasını inceleyebilirsiniz.

---

## 💖 Sponsorluk ve Destek

NotesMy günlük iş akışınızı hızlandırıyor ve hayatınızı kolaylaştırıyorsa projeye sponsor olabilir veya bir kahve ısmarlayabilirsiniz:

<p align="center">
  <a href="https://github.com/sponsors/mehmetefeaytas"><img src="https://img.shields.io/badge/GitHub%20Sponsors-Destek%20Ol-EA4AAA?style=for-the-badge&logo=githubsponsors" alt="GitHub Sponsors" /></a>
  &nbsp;&nbsp;
  <a href="https://buymeacoffee.com/mehmetefeaytas"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Ba%C4%9F%C4%B1%C5%9F-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=black" alt="Buy Me a Coffee" /></a>
</p>

---

## 📬 İletişim & Bağlantı

Geri bildirim, iş birliği ve sorularınız için:

- 📧 **E-posta:** [efeyapiyor@gmail.com](mailto:efeyapiyor@gmail.com)
- 💼 **LinkedIn:** [Mehmet Efe Aytaş](https://linkedin.com/in/mehmetefeaytas)
- 🐙 **GitHub:** [@mehmetefeaytas](https://github.com/mehmetefeaytas)

---

## 📄 Lisans

NotesMy, **Apache License 2.0** kapsamında lisanslanmıştır. Detaylar için [LICENSE](../LICENSE) dosyasına bakabilirsiniz.

**[Mehmet Efe Aytaş](https://github.com/mehmetefeaytas)** tarafından ❤️ ile geliştirilmiştir.
