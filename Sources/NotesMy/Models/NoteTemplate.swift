import Foundation

public struct NoteTemplate: Identifiable, Sendable {
    public var id: String
    public var title: String
    public var titleTr: String
    public var icon: String
    public var category: String
    public var bodyTemplate: String
    public var bodyTemplateTr: String

    public init(
        id: String,
        title: String,
        titleTr: String,
        icon: String,
        category: String,
        bodyTemplate: String,
        bodyTemplateTr: String
    ) {
        self.id = id
        self.title = title
        self.titleTr = titleTr
        self.icon = icon
        self.category = category
        self.bodyTemplate = bodyTemplate
        self.bodyTemplateTr = bodyTemplateTr
    }

    public static let builtInTemplates: [NoteTemplate] = [
        NoteTemplate(
            id: "meeting",
            title: "Meeting Notes",
            titleTr: "Toplantı Notu",
            icon: "person.3.fill",
            category: "Work",
            bodyTemplate: """
            ## 🎯 Meeting: [Topic]
            **Date:** \(Date().formatted(date: .abbreviated, time: .shortened))
            **Attendees:** @Person1, @Person2

            ### 📌 Agenda
            - Objective 1
            - Objective 2

            ### 💬 Discussion & Decisions
            - Point A
            - Point B

            ### ✅ Action Items
            - [ ] Follow up on deliverables
            - [ ] Send summary email
            """,
            bodyTemplateTr: """
            ## 🎯 Toplantı: [Konu]
            **Tarih:** \(Date().formatted(date: .abbreviated, time: .shortened))
            **Katılımcılar:** @Kişi1, @Kişi2

            ### 📌 Gündem
            - 1. Madde
            - 2. Madde

            ### 💬 Alınan Kararlar
            - Karar A
            - Karar B

            ### ✅ Eylem Planı
            - [ ] İlgili kişilerle iletişime geç
            - [ ] Özet e-postasını gönder
            """
        ),
        NoteTemplate(
            id: "daily_planner",
            title: "Daily Smart Planner",
            titleTr: "Akıllı Günlük Plan",
            icon: "calendar.badge.clock",
            category: "Personal",
            bodyTemplate: """
            ## 📅 Daily Planner - \(Date().formatted(date: .complete, time: .omitted))

            ### 🎯 Top 3 Priorities
            - [ ] 1. Core Milestone
            - [ ] 2. Important task
            - [ ] 3. Review & cleanup

            ### ⏱️ Schedule & Deep Work
            - 09:00 - 11:00: Deep focus
            - 14:00 - 15:30: Team alignment

            ### 💡 Evening Reflection
            - What went well today?
            """,
            bodyTemplateTr: """
            ## 📅 Günlük Plan - \(Date().formatted(date: .complete, time: .omitted))

            ### 🎯 Günün 3 Ana Hedefi
            - [ ] 1. En kritik görev
            - [ ] 2. Önemli teslimat
            - [ ] 3. Notları ve mailleri gözden geçir

            ### ⏱️ Zaman Blokları
            - 09:00 - 11:30: Odaklanmış çalışma
            - 14:00 - 15:00: Toplantılar ve koordinasyon

            ### 💡 Gün Sonu Değerlendirmesi
            - Bugün neleri başardım?
            """
        ),
        NoteTemplate(
            id: "code_review",
            title: "Code Review & Architecture",
            titleTr: "Kod İnceleme & Mimari",
            icon: "chevron.left.forwardslash.chevron.right",
            category: "Code",
            bodyTemplate: """
            ## 💻 PR / Architecture Review: [Component]
            **Branch:** `feature/new-module`
            **PR Link:** https://github.com/...

            ### 🔍 Overview & Design
            - What problem does this solve?
            - Architectural tradeoffs & considerations

            ### 📋 Review Checklist
            - [ ] Zero regression in core flows
            - [ ] Unit tests added with >80% coverage
            - [ ] Memory leaks / Sendable checked
            - [ ] Documentation updated
            """,
            bodyTemplateTr: """
            ## 💻 PR / Mimari İnceleme: [Bileşen]
            **Dal (Branch):** `feature/yeni-ozellik`
            **PR Linki:** https://github.com/...

            ### 🔍 Genel Bakış ve Tasarım
            - Çözülen problem nedir?
            - Mimari kararlar ve alternatifler

            ### 📋 İnceleme Kontrol Listesi
            - [ ] Mevcut akışlarda bozulma yok
            - [ ] Birim testler eklendi
            - [ ] Performans ve bellek kullanımı kontrol edildi
            - [ ] Dokümantasyon güncellendi
            """
        ),
        NoteTemplate(
            id: "brainstorm",
            title: "Brainstorming & Ideas",
            titleTr: "Beyin Fırtınası & Fikirler",
            icon: "lightbulb.fill",
            category: "Ideas",
            bodyTemplate: """
            ## 💡 Brainstorm: [Challenge / Opportunity]

            ### ❓ The Core Problem
            What needs solving?

            ### 🚀 Wild Ideas & Concepts
            - Idea 1: ...
            - Idea 2: ...
            - Idea 3: ...

            ### ⚖️ Pros & Cons
            | Concept | Pros | Cons |
            | :--- | :--- | :--- |
            | Option A | Fast | Tech debt |
            | Option B | Scalable | Takes 2 weeks |

            ### 🎯 Selected Direction
            - Next steps:
            """,
            bodyTemplateTr: """
            ## 💡 Beyin Fırtınası: [Fırsat / Fikir]

            ### ❓ Çözülecek Problem
            Hangi ihtiyaca çözüm üretiyoruz?

            ### 🚀 Fikirler ve Konseptler
            - Fikir 1: ...
            - Fikir 2: ...
            - Fikir 3: ...

            ### ⚖️ Artılar & Eksiler
            | Fikir | Artıları | Riskleri |
            | :--- | :--- | :--- |
            | A Seçeneği | Hızlı uygulanır | Geçici çözüm |
            | B Seçeneği | Sağlam ve ölçeklenebilir | Ekstra geliştirme süresi |

            ### 🎯 Seçilen Yol
            - İlk adım:
            """
        ),
        NoteTemplate(
            id: "bug_report",
            title: "Bug & Issue Tracker",
            titleTr: "Hata Raporu (Bug Report)",
            icon: "ant.fill",
            category: "Code",
            bodyTemplate: """
            ## 🐛 Bug: [Short Description]
            **Severity:** High / Medium / Low
            **Environment:** macOS 15, NotesMy v1.4

            ### 🔁 Steps to Reproduce
            1. Step one
            2. Step two
            3. Observe unexpected behavior

            ### ❌ Expected vs. Actual
            - **Expected:** ...
            - **Actual:** ...

            ### 🛠️ Fix Investigation
            - [ ] Reproduce locally
            - [ ] Write failing test
            - [ ] Submit hotfix
            """,
            bodyTemplateTr: """
            ## 🐛 Hata: [Kısa Açıklama]
            **Önem Derecesi:** Yüksek / Orta / Düşük
            **Ortam:** macOS 15, NotesMy v1.4

            ### 🔁 Tekrarlama Adımları
            1. İlk adım
            2. İkinci adım
            3. Hatalı durumu gözlemle

            ### ❌ Beklenen vs. Gerçekleşen
            - **Beklenen:** ...
            - **Gerçekleşen:** ...

            ### 🛠️ Çözüm Takibi
            - [ ] Hatayı yerel ortamda tekrar et
            - [ ] Birim test ekle
            - [ ] Düzeltmeyi uygula ve yayınla
            """
        ),
        NoteTemplate(
            id: "project_roadmap",
            title: "Project Roadmap & Sprint",
            titleTr: "Proje Yol Haritası & Sprint",
            icon: "flag.checkered",
            category: "Work",
            bodyTemplate: """
            ## 🚀 Project Roadmap: [Milestone]
            > [!NOTE]
            > High-level roadmap and feature status for the upcoming release.

            ### 📊 Milestone & Feature Matrix
            | Feature | Owner | Priority | Status |
            | :--- | :--- | :---: | :---: |
            | Markdown Table Support | @Engineer | 🔴 High | ✅ Done |
            | Notion-style Callouts | @Design | 🟡 Medium | ⏳ In Progress |
            | Export to CSV / Markdown | @Team | 🟢 Low | 📝 Backlog |

            ### 🎯 Target Release Date: \(Date().addingTimeInterval(86400 * 14).formatted(date: .abbreviated, time: .omitted))
            - [ ] Complete integration tests
            - [ ] Create GitHub release tag
            """,
            bodyTemplateTr: """
            ## 🚀 Proje Yol Haritası: [Aşama / Sürüm]
            > [!NOTE]
            > Yaklaşan sürüm için ana hedefler ve teslimat tablosu.

            ### 📊 Teslimat & Durum Tablosu
            | Özellik / Görev | Sorumlu | Öncelik | Durum |
            | :--- | :--- | :---: | :---: |
            | Tablo Desteği & Format Barı | @Efe | 🔴 Yüksek | ✅ Tamamlandı |
            | Notion Tarzı Bilgi Kutuları | @Tasarım | 🟡 Orta | ⏳ Devam Ediyor |
            | CSV / MD Olarak Dışa Aktarma | @Ekip | 🟢 Düşük | 📝 Bekliyor |

            ### 🎯 Hedef Yayın Tarihi: \(Date().addingTimeInterval(86400 * 14).formatted(date: .abbreviated, time: .omitted))
            - [ ] Entegrasyon testlerini tamamla
            - [ ] GitHub sürüm etiketini oluştur
            """
        ),
        NoteTemplate(
            id: "budget_planner",
            title: "Budget & Expense Sheet",
            titleTr: "Bütçe & Harcama Tablosu",
            icon: "creditcard.fill",
            category: "Personal",
            bodyTemplate: """
            ## 💰 Budget & Expense Tracker
            > [!TIP]
            > Keep track of ongoing subscriptions and project costs.

            ### 💳 Expenses Matrix
            | Expense Item | Category | Amount ($) | Status |
            | :--- | :--- | ---: | :---: |
            | Cloud Server & Storage | Infrastructure | 45.00 | ✅ Paid |
            | Domain Renewal | Hosting | 14.99 | ✅ Paid |
            | Design Tools & Fonts | Assets | 30.00 | ⏳ Pending |
            | **Total** | - | **$89.99** | - |

            ### 📌 Financial Goals
            - [ ] Keep monthly infra spend under $100
            - [ ] Review unused SaaS subscriptions
            """,
            bodyTemplateTr: """
            ## 💰 Bütçe & Harcama Tablosu
            > [!TIP]
            > Aylık sabit giderleri ve proje masraflarını takip edin.

            ### 💳 Harcama Kalemleri
            | Harcama Kalemi | Kategori | Tutar (₺) | Durum |
            | :--- | :--- | ---: | :---: |
            | Bulut Sunucu & Veritabanı | Altyapı | 1.250 | ✅ Ödendi |
            | Alan Adı (Domain) Yenileme | Domain | 450 | ✅ Ödendi |
            | Tasarım & Görsel Lisansı | Varlıklar | 800 | ⏳ Bekliyor |
            | **Genel Toplam** | - | **2.500 ₺** | - |

            ### 📌 Tasarruf Hedefleri
            - [ ] Aylık altyapı maliyetini bütçe sınırında tut
            - [ ] Kullanılmayan SaaS aboneliklerini iptal et
            """
        ),
        NoteTemplate(
            id: "habit_tracker",
            title: "Weekly Habit & Health Tracker",
            titleTr: "Haftalık Alışkanlık & Hedefler",
            icon: "flame.fill",
            category: "Personal",
            bodyTemplate: """
            ## 🔥 Weekly Habit Tracker
            > [!SUCCESS]
            > Consistency beats intensity. Track your daily wins!

            ### 📅 Daily Consistency Matrix
            | Habit / Routine | Mon | Tue | Wed | Thu | Fri | Sat | Sun |
            | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
            | 🏃 30m Exercise | ✅ | ✅ | ⏳ | - | - | - | - |
            | 📖 Read 20 Pages | ✅ | ✅ | ✅ | - | - | - | - |
            | 💻 90m Deep Work | ✅ | ✅ | ⏳ | - | - | - | - |
            | 💧 2.5L Water | ✅ | ⏳ | - | - | - | - | - |

            ### 💡 Reflection
            - What habit was easiest to stick to this week?
            """,
            bodyTemplateTr: """
            ## 🔥 Haftalık Alışkanlık & Hedefler
            > [!SUCCESS]
            > Küçük ve düzenli adımlar büyük başarılar getirir!

            ### 📅 Günlük Alışkanlık Takip Tablosu
            | Alışkanlık / Rutin | Pzt | Sal | Çar | Per | Cum | Cmt | Paz |
            | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
            | 🏃 30 Dk Spor / Yürüyüş | ✅ | ✅ | ⏳ | - | - | - | - |
            | 📖 20 Sayfa Kitap Oku | ✅ | ✅ | ✅ | - | - | - | - |
            | 💻 90 Dk Derin Çalışma | ✅ | ✅ | ⏳ | - | - | - | - |
            | 💧 2.5 Litre Su İç | ✅ | ⏳ | - | - | - | - | - |

            ### 💡 Hafta Sonu Değerlendirmesi
            - Bu hafta hangi alışkanlıkta en istikrarlıydın?
            """
        )
    ]
}
