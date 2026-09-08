# 🇸🇦 NotesMy — العقل الثاني المدعوم بالذكاء الاصطناعي والملاحظات اللاصقة لنظام macOS

<p align="center">
  <img src="../assets/app_icon_1024.png" alt="NotesMy App Icon" width="128" height="128" style="border-radius: 28px; box-shadow: 0 8px 24px rgba(0,0,0,0.25);" />
</p>

<h2 align="center">ملاحظات لاصقة سلسة مثبتة على حافة الشاشة وإدارة المعرفة الشخصية لنظام macOS</h2>

<p align="center">
  <a href="../README.md">🇬🇧 English</a> · 
  <a href="README_tr.md">🇹🇷 Türkçe</a> · 
  <a href="README_de.md">🇩🇪 Deutsch</a> · 
  <a href="README_fr.md">🇫🇷 Français</a> · 
  <a href="README_es.md">🇪🇸 Español</a> · 
  <a href="README_pt.md">🇧🇷 Português</a> · 
  <a href="README_it.md">🇮🇹 Italiano</a> · 
  <a href="README_ru.md">🇷🇺 Русский</a> · 
  <a href="README_ja.md">🇯🇵 日本語</a> · 
  <a href="README_ko.md">🇰🇷 한국어</a> · 
  <strong>[🇸🇦 العربية](README_ar.md)</strong> · 
  <a href="README_zh.md">🇨🇳 中文</a>
</p>

<p align="center">
  <a href="https://github.com/mehmetefeaytas/notesmy/releases"><img src="https://img.shields.io/github/v/release/mehmetefeaytas/notesmy?style=for-the-badge&color=8B5CF6" alt="Release" /></a>
  <a href="https://github.com/mehmetefeaytas/homebrew-tap"><img src="https://img.shields.io/badge/Homebrew-Cask%20%D9%85%D8%AA%D8%A7%D8%AD-orange?style=for-the-badge&logo=homebrew" alt="Homebrew" /></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?style=for-the-badge&logo=apple" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift" alt="Swift 6" />
  <img src="https://img.shields.io/badge/%D8%A7%D9%84%D8%A8%D9%86%D9%8A%D8%A9-Universal%20(ARM64%20%2B%20x86__64)-green?style=for-the-badge" alt="Universal Binary" />
  <img src="https://img.shields.io/badge/%D8%A7%D9%84%D8%AE%D8%B5%D9%88%D8%B5%D9%8A%D8%A9-100%25%20%D8%B9%D9%84%D9%89%20%D8%A7%D9%84%D8%AC%D9%87%D8%A7%D8%B2-success?style=for-the-badge" alt="الخصوصية" />
  <img src="https://img.shields.io/badge/%D8%A7%D9%84%D8%AA%D8%B1%D8%AE%D9%8A%D8%B5-Apache%202.0-yellow?style=for-the-badge" alt="Apache 2.0" />
</p>

---

## 🎬 العرض التوضيحي الحي

<p align="center">
  <img src="../assets/demo.gif" alt="NotesMy Live Demo" width="100%" style="border-radius: 12px; box-shadow: 0 12px 36px rgba(0,0,0,0.25);" />
</p>
<p align="center">
  <em>تسجيل شاشة عالي الدقة يوضح الانزلاق السلس من حافة الشاشة، والتقاط الملاحظات الفوري، واللوحة الحرة، واستخراج النصوص الفوري عبر تقنية OCR. (<a href="../assets/demo.mp4">تحميل فيديو MP4 بجودة 60 إطاراً</a>)</em>
</p>

---

## ⚡ ما هو تطبيق NotesMy؟

**NotesMy** هو تطبيق أصلي وفائق السرعة لنظام macOS يجمع بين سرعة الملاحظات اللاصقة (*Unclutter* و *SideNotes*) وقوة قواعد المعرفة المترابطة الحديثة (*Obsidian* و *Apple Notes*).

تم بناؤه بالكامل باستخدام **Swift 6 و SwiftUI و AppKit**، ليبقى مستقراً في شريط القوائم بهدوء وينزلق بسلاسة من جانب الشاشة بمجرد تحريك المؤشر أو الضغط على اختصار مخصص.

### ✨ أبرز المميزات

- 🪟 **درج حافة الشاشة (Edge Deck):** حرّك المؤشر إلى حافة الشاشة لتكشف عن بطاقات ملاحظاتك النشطة في عرض مروحي متحرك.
- 🔄 **تحديثات تلقائية مدمجة:** فحص إصدارات GitHub مباشرة من الإعدادات، استعراض سجل التغييرات، شريط تقدم تحميل DMG، وتحديث بنقرة واحدة.
- ⌨️ **التنقل بين الفئات بأسهم لوحة المفاتيح:** تنقل أفقي سلس بين الوسوم والأقسام باستخدام الأسهم (`←` / `→`) أو أزرار التمرير.
- 🗑️ **حذف سريع وتنظيف الملاحظات المهملة:** إمكانية الحذف الفوري بنقرة واحدة على البطاقة؛ كشف تلقائي وأرشفة للملاحظات التي لم تُعدل لأكثر من 30 يوماً.
- ⚙️ **إغلاق آمن للنوافذ:** زر الإغلاق الأحمر في نافذة الإعدادات لا يغلق التطبيق؛ نافذة تأكيد على مرحلتين عند مسح البيانات.
- 🧠 **رسم بياني للمعرفة بالذكاء الاصطناعي مع محاكاة فيزيائية:** محاكاة كولوم وهوك الفيزيائية، تشابه مفاهيم جاكارد، روابط ثنائية الاتجاه `[[WikiLinks]]`، وخطوط ملونة مضيئة متصلة وواضحة عند تحديد الملاحظات.
- 🔍 **استخراج النصوص من الشاشة (OCR):** حدد أي جزء من شاشتك لنسخ النصوص منه فوراً إلى الحافظة أو إلى ملاحظتك عبر Apple Vision.
- 🎙️ **ملاحظات صوتية على الجهاز:** تحويل الكلام إلى نصوص فوري يدعم 12 لغة دون أي تأخير ودون انتهاك للخصوصية.
- 📌 **لوحة الملاحظات الحرة (Sticky Board):** رتّب الملاحظات كبطاقات ملونة على لوحة فلينية لا نهائية قابلة للتكبير والسحب.
- 🎨 **لوحات ألوان باستيل هادئة:** 6 ألوان باستيل مريحة للعين، تنسيق Markdown غني، قوائم مهام، وتنسيق الأكواد البرمجية.
- 🛡️ **بدون بيانات تتبع ويعمل 100% بدون إنترنت:** لا خوادم خارجية ولا تسجيل حسابات. تعمل كافة نماذج الذكاء الاصطناعي محلياً على جهازك.

---

## 🍺 التثبيت عبر Homebrew

الطريقة الموصى بها للتثبيت والتحديث المستمر على macOS:

```bash
# 1. إضافة المستودع
brew tap mehmetefeaytas/tap

# 2. تثبيت NotesMy
brew install --cask notesmy
```

### التحديث
```bash
brew upgrade --cask notesmy
```

### التحميل اليدوي (DMG)
إذا كنت تفضل تنزيل ملف DMG الشامل مباشرة، يمكنك تنزيل أحدث إصدار من صفحة [GitHub Releases](https://github.com/mehmetefeaytas/notesmy/releases/latest).

> **ملاحظة Gatekeeper (عند التشغيل لأول مرة):** نظراً لتوزيع التطبيق كبرمجية مفتوحة المصدر مستقلة، قد يُظهر macOS تنبيهاً أمنياً. انقر بزر الفأرة الأيمن على `NotesMy.app` داخل مجلد `/Applications` واختر **Open**، أو نفّذ الأمر التالي في Terminal:
> ```bash
> xattr -cr /Applications/NotesMy.app
> ```

---

## 📸 لقطات شاشة للتطبيق

<table width="100%">
  <tr>
    <td width="50%">
      <h3 align="center">🗂️ جميع الملاحظات والبحث الدلالي</h3>
      <img src="../assets/preview-allnotes.png" alt="نافذة جميع الملاحظات" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🪟 درج حافة الشاشة الجانبي</h3>
      <img src="../assets/preview-edge-deck.png" alt="NotesMy Edge Deck" width="100%" />
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3 align="center">📝 محرر الملاحظات البسيط</h3>
      <img src="../assets/preview-note.png" alt="محرر الملاحظات" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🎨 أيقونة عصرية بألوان باستيل</h3>
      <img src="../assets/app_icon_1024.png" alt="أيقونة NotesMy" width="60%" style="display: block; margin: 0 auto;" />
    </td>
  </tr>
</table>

---

## 💎 جدول المزايا الكاملة

| المستوى | الميزة | الحالة | التقنية المستخدمة |
| :--- | :--- | :---: | :--- |
| **V1 — الأساسي** | ملاحظات نصية وقوائم مهام بألوان باستيل | ✅ | محرر نصوص SwiftUI أصلي |
| **V1 — الأساسي** | درج مروحي مثبت على حافة الشاشة | ✅ | لوحة AppKit NSPanel عائمة |
| **V1 — الأساسي** | الوسوم، الأقسام، التثبيت، والمفضلة | ✅ | تخزين محلي بتنسيق JSON |
| **V1 — الأساسي** | التنقل بالأسهم (`←` / `→`) بين الفئات | ✅ | AppKit Event Monitor + ScrollViewReader |
| **V1 — الأساسي** | حذف سريع بنقرة واحدة من صف البطاقة | ✅ | معالج أوامر Swift |
| **V1 — الأساسي** | سجل الحافظة مع التقاط تلقائي للنصوص | ✅ | مراقب NSPasteboard |
| **V1 — الأساسي** | منتقي ألوان تفاعلي ونوافذ قابلة لتعديل الحجم | ✅ | AppKit NSWindow + SwiftUI |
| **V2 — المتقدم** | ملاحظات صوتية تدعم 12 لغة (إملاء فوري) | ✅ | Apple SFSpeechRecognizer |
| **V2 — المتقدم** | استخراج النصوص من الشاشة عبر Vision OCR | ✅ | Apple Vision + screencapture |
| **V2 — المتقدم** | لوحة ملاحظات حرة وتفاعلية (Sticky Board) | ✅ | لوحة SwiftUI تدعم السحب والإفلات |
| **V2 — المتقدم** | أرشفة وتنظيف تلقائي للملاحظات المهملة (>30 يوماً) | ✅ | محرك فحص النشاط الزمني |
| **V2 — المتقدم** | تمييز ذكي للمواعيد والتنبيهات باللغة الطبيعية | ✅ | NSDataDetector + UserNotifications |
| **V2 — المتقدم** | بحث متجهي دلالي حسب المعنى والمفاهيم | ✅ | تضمينات Apple NaturalLanguage |
| **V3 — المتصل** | تحديثات آلية مدمجة وفحص إصدارات GitHub | ✅ | GitHub REST API + URLSession |
| **V3 — المتصل** | أداة Web Clipper لقص الروابط وتلخيصها | ✅ | WebKit + URLSession |
| **V3 — المتصل** | تصدير مواعيد التقويم بنقرة واحدة (.ics) | ✅ | مولد تقويمات قياسي RFC 5545 |
| **V3 — المتصل** | تصدير مباشر إلى ملاحظات Apple والتذكيرات | ✅ | NSSharingService + EventKit |
| **V3 — المتصل** | مزامنة خاصة مع CloudKit ونسخ احتياطي محلي | ✅ | حاوية Apple CloudKit الخاصة |
| **V3 — المتصل** | سجل الإصدارات مع إمكانية الرجوع عبر الزمن | ✅ | لقطات تراكمية للبيانات |
| **V4 — العقل الثاني** | رسم بياني للمعرفة بمحاكاة فيزيائية كولوم-هوك | ✅ | محاكاة رياضية فيزيائية + Canvas |
| **V4 — العقل الثاني** | خطوط اتصال متصلة وملونة وساطعة عند التحديد | ✅ | مسارات رسومية متجهة في SwiftUI |
| **V4 — العقل الثاني** | روابط تبادلية `[[WikiLinks]]` مع فهرس مراجع | ✅ | محلل الروابط بالتعبيرات النمطية |
| **V4 — العقل الثاني** | محادثة ذكاء اصطناعي محلية مع مجمل ملاحظاتك | ✅ | معمارية RAG المحلية على الجهاز |
| **V4 — العقل الثاني** | استخراج خطط العمل اليومية والمهام | ✅ | استخراج المهام باللغة الطبيعية |
| **V4 — العقل الثاني** | ترتيب وتنظيم الأفكار المشتتة آلياً | ✅ | محرك معالجة Apple Intelligence |

---

## 🌍 اللغات المدعومة (12 لغة)

يتعرف NotesMy تلقائياً على لغة نظام macOS، ويوفر واجهة استخدام وإملاء صوتي كاملين في اللغات التالية:

| العلم | اللغة | العلم | اللغة | العلم | اللغة |
| :---: | :--- | :---: | :--- | :---: | :--- |
| 🇬🇧 | English | 🇹🇷 | Türkçe | 🇩🇪 | Deutsch |
| 🇫🇷 | Français | 🇪🇸 | Español | 🇧🇷 | Português (البرازيل) |
| 🇮🇹 | Italiano | 🇷🇺 | Русский | 🇯🇵 | 日本語 |
| 🇰🇷 | 한국어 | 🇸🇦 | العربية (RTL) | 🇨🇳 | 简体中文 |

---

## ⌨️ اختصارات لوحة المفاتيح الرئيسية

يمكنك تعديل الاختصارات من خلال **الإعدادات → الاختصارات**:

| الاختصار الافتراضي | الإجراء | الوصف |
| :--- | :--- | :--- |
| `⌥⌘N` | **ملاحظة جديدة** | تفتح فوراً نافذة ملاحظة لاصقة عائمة على الشاشة |
| `⌥⌘V` | **التقاط سريع** | تحول محتوى الحافظة مباشرة إلى ملاحظة جديدة |
| `⌥⌘L` | **جميع الملاحظات** | تفتح لوحة الإدارة والبحث الدلالي الشامل |
| `⌥⌘B` | **لوحة الملاحظات** | تفتح اللوحة الفلينية الحرة |
| `⌥⌘A` | **الأرشيف** | تستعرض الملاحظات المؤرشفة |
| `⌃⌥⌘H` | **تبديل الدرج** | تظهر أو تخفي درج حافة الشاشة |
| `Esc` | **إغلاق الملاحظة** | تغلق نافذة الملاحظة النشطة في المقدمة |

---

## 📈 سجل الإعجابات (Stars)

[![Star History Chart](https://api.star-history.com/svg?repos=mehmetefeaytas/notesmy&type=Date)](https://star-history.com/#mehmetefeaytas/notesmy&Date)

---

## 👥 المساهمون

نرحب دائماً بالمساهمات، واقتراح الخصائص، والإبلاغ عن أي أخطاء!

<a href="https://github.com/mehmetefeaytas/notesmy/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=mehmetefeaytas/notesmy" alt="المساهمون" />
</a>

راجع ملف [CONTRIBUTING.md](../CONTRIBUTING.md) للتعرف على إرشادات التطوير والاختبار.

---

## 💖 الرعاية والدعم

إذا كان NotesMy يساهم في تسهيل عملك اليومي على Mac، يمكنك دعم تطويره أو التبرع بفنجان قهوة:

<p align="center">
  <a href="https://github.com/sponsors/mehmetefeaytas"><img src="https://img.shields.io/badge/GitHub%20Sponsors-%D8%AF%D8%B9%D9%85-EA4AAA?style=for-the-badge&logo=githubsponsors" alt="GitHub Sponsors" /></a>
  &nbsp;&nbsp;
  <a href="https://buymeacoffee.com/mehmetefeaytas"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-%D9%82%D9%87%D9%88%D8%A9-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=black" alt="Buy Me a Coffee" /></a>
</p>

---

## 📬 التواصل والروابط

لأي استفسار أو اقتراح للتعاون:

- 📧 **البريد الإلكتروني:** [efeyapiyor@gmail.com](mailto:efeyapiyor@gmail.com)
- 💼 **LinkedIn:** [Mehmet Efe Aytaş](https://linkedin.com/in/mehmetefeaytas)
- 🐙 **GitHub:** [@mehmetefeaytas](https://github.com/mehmetefeaytas)

---

## 🛡️ الخصوصية والأمان

- **عمل محلي 100%:** لا يقوم NotesMy بأي اتصال بخوادم خارجية. لا تتبع ولا جمع بيانات على الإطلاق.
- **ملفات محلية آمنة:** تُحفظ كافة بياناتك محلياً في المسار `~/Library/Application Support/NotesMy/notes.json`.
- **مزامنة CloudKit:** في حال تفعيلها، تتم المزامنة عبر حساب iCloud الشخصي المشفر الخاص بك فقط.

---

## 📄 الترخيص

NotesMy مرخص بموجب ترخيص **Apache License 2.0**. راجع ملف [LICENSE](../LICENSE) لمزيد من التفاصيل.

تم التطوير بكل ❤️ بواسطة **[Mehmet Efe Aytaş](https://github.com/mehmetefeaytas)**.
