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
        )
    ]
}
