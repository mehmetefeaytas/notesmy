import Foundation
import NaturalLanguage

public final class MeetingAIService: Sendable {
    public static let shared = MeetingAIService()

    private init() {}

    // MARK: - Main Note Generation
    public func generateMeetingNote(
        metadata: MeetingMetadata,
        transcriptEntries: [MeetingTranscriptEntry],
        userNotes: String,
        template: MeetingTemplate,
        isTurkish: Bool
    ) -> String {
        switch template {
        case .executiveSummary:
            return buildExecutiveSummary(metadata: metadata, transcript: transcriptEntries, userNotes: userNotes, isTurkish: isTurkish)
        case .actionItems:
            return buildActionItemsReport(metadata: metadata, transcript: transcriptEntries, userNotes: userNotes, isTurkish: isTurkish)
        case .formalMoM:
            return buildFormalMoM(metadata: metadata, transcript: transcriptEntries, userNotes: userNotes, isTurkish: isTurkish)
        case .agileStandup:
            return buildAgileStandup(metadata: metadata, transcript: transcriptEntries, userNotes: userNotes, isTurkish: isTurkish)
        case .oneOnOne:
            return buildOneOnOne(metadata: metadata, transcript: transcriptEntries, userNotes: userNotes, isTurkish: isTurkish)
        case .brainstorming:
            return buildBrainstorming(metadata: metadata, transcript: transcriptEntries, userNotes: userNotes, isTurkish: isTurkish)
        case .followUpEmail:
            return buildFollowUpEmail(metadata: metadata, transcript: transcriptEntries, userNotes: userNotes, isTurkish: isTurkish)
        case .fullTranscript:
            return buildFullTranscriptView(metadata: metadata, transcript: transcriptEntries, userNotes: userNotes, isTurkish: isTurkish)
        }
    }

    // MARK: - 1. Executive Summary
    private func buildExecutiveSummary(
        metadata: MeetingMetadata,
        transcript: [MeetingTranscriptEntry],
        userNotes: String,
        isTurkish: Bool
    ) -> String {
        let title = metadata.title.isEmpty ? (isTurkish ? "Toplantı Özeti" : "Meeting Summary") : metadata.title
        let dateStr = metadata.date.formatted(date: .abbreviated, time: .shortened)
        let actions = extractActionItems(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)
        let decisions = extractKeyDecisions(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)
        let highlights = extractKeyHighlights(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)

        var doc = ""
        doc += "# 📌 \(title)\n\n"
        doc += "> [!NOTE]\n"
        doc += "> **\(isTurkish ? "Tarih" : "Date"):** \(dateStr)  \n"
        doc += "> **\(isTurkish ? "Süre" : "Duration"):** \(metadata.formattedDuration)  \n"
        doc += "> **\(isTurkish ? "Mod" : "Mode"):** \(metadata.mode.title(isTurkish: isTurkish))  \n"
        if !metadata.attendees.isEmpty {
            doc += "> **\(isTurkish ? "Katılımcılar" : "Attendees"):** \(metadata.attendees.joined(separator: ", "))\n"
        }
        doc += "\n"

        // Executive Synthesis
        doc += "## 💡 \(isTurkish ? "Yönetici Özeti" : "Executive Summary")\n\n"
        if highlights.isEmpty {
            doc += isTurkish
                ? "Toplantı boyunca gündem maddeleri ve genel ilerleme durumu değerlendirildi. Ekipler arası koordinasyon ve önümüzdeki dönem hedefleri ele alındı.\n\n"
                : "During the meeting, key agenda items and current progress were evaluated. Cross-team alignment and upcoming objectives were reviewed.\n\n"
        } else {
            for h in highlights {
                doc += "• \(h)\n"
            }
            doc += "\n"
        }

        // Decisions
        if !decisions.isEmpty {
            doc += "## ⚖️ \(isTurkish ? "Alınan Temel Kararlar" : "Key Decisions Ratified")\n\n"
            for d in decisions {
                doc += "- 🎯 **\(d)**\n"
            }
            doc += "\n"
        }

        // Action Items
        doc += "## ✅ \(isTurkish ? "Öncelikli Aksiyonlar & Görev Dağılımı" : "Action Items & Next Steps")\n\n"
        if actions.isEmpty {
            doc += "- [ ] \(isTurkish ? "Toplantı notlarını gözden geçir ve ilgili ekiplerle paylaş" : "Review meeting notes and share with relevant team members")\n"
        } else {
            for a in actions {
                doc += "- [ ] \(a)\n"
            }
        }
        doc += "\n"

        // Live Notes if user typed any
        if !userNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            doc += "## 📝 \(isTurkish ? "Toplantı Sırasında Alınan Notlar" : "In-Meeting User Notes")\n\n"
            doc += userNotes.trimmingCharacters(in: .whitespacesAndNewlines) + "\n\n"
        }

        // Collapsible Transcript at end
        doc += appendCollapsibleTranscript(transcript: transcript, isTurkish: isTurkish)
        return doc
    }

    // MARK: - 2. Action Items Focus
    private func buildActionItemsReport(
        metadata: MeetingMetadata,
        transcript: [MeetingTranscriptEntry],
        userNotes: String,
        isTurkish: Bool
    ) -> String {
        let title = metadata.title.isEmpty ? (isTurkish ? "Aksiyon ve Görev Takip Raporu" : "Action Items & Deliverables") : metadata.title
        let actions = extractActionItems(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)
        let blockers = extractBlockers(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)

        var doc = ""
        doc += "# ✅ \(title)\n\n"
        doc += "> **\(isTurkish ? "Toplantı Tarihi" : "Meeting Date"):** \(metadata.date.formatted(date: .complete, time: .shortened)) | **\(isTurkish ? "Süre" : "Duration"):** \(metadata.formattedDuration)\n\n"

        doc += "## 📋 \(isTurkish ? "Yapılacaklar Listesi" : "Task Checklist")\n\n"
        if actions.isEmpty {
            doc += "- [ ] \(isTurkish ? "Aksiyon adımlarını netleştir" : "Confirm upcoming deliverables")\n"
        } else {
            for (idx, a) in actions.enumerated() {
                let priorityTag = idx < 2 ? (isTurkish ? "🔴 [Yüksek]" : "🔴 [High]") : (isTurkish ? "🟡 [Normal]" : "🟡 [Medium]")
                doc += "- [ ] \(priorityTag) \(a)\n"
            }
        }
        doc += "\n"

        if !blockers.isEmpty {
            doc += "## ⚠️ \(isTurkish ? "Engeller & Çözülmesi Gereken Riskler" : "Blockers & Risks")\n\n"
            for b in blockers {
                doc += "- ⚠️ \(b)\n"
            }
            doc += "\n"
        }

        if !userNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            doc += "## 📝 \(isTurkish ? "Canlı Notlar" : "Meeting Scratchpad")\n\n"
            doc += userNotes.trimmingCharacters(in: .whitespacesAndNewlines) + "\n\n"
        }

        doc += appendCollapsibleTranscript(transcript: transcript, isTurkish: isTurkish)
        return doc
    }

    // MARK: - 3. Formal Minutes of Meeting (MoM)
    private func buildFormalMoM(
        metadata: MeetingMetadata,
        transcript: [MeetingTranscriptEntry],
        userNotes: String,
        isTurkish: Bool
    ) -> String {
        let title = metadata.title.isEmpty ? (isTurkish ? "Resmi Toplantı Tutanağı" : "Minutes of Meeting (MoM)") : metadata.title
        let dateStr = metadata.date.formatted(date: .complete, time: .shortened)
        let decisions = extractKeyDecisions(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)
        let actions = extractActionItems(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)
        let highlights = extractKeyHighlights(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)

        var doc = ""
        doc += "# 📄 \(title)\n\n"
        doc += "> 🏛️ **\(isTurkish ? "Resmi Toplantı Tutanağı (MoM)" : "Official Minutes of Meeting")**\n\n"
        doc += "### 🏛️ \(isTurkish ? "Toplantı Kimlik Bilgileri" : "Meeting Metadata")\n\n"
        doc += "| \(isTurkish ? "Alan" : "Field") | \(isTurkish ? "Detay" : "Details") |\n"
        doc += "| :--- | :--- |\n"
        doc += "| **\(isTurkish ? "Toplantı Adı" : "Meeting Title")** | \(escapeMarkdown(title)) |\n"
        doc += "| **\(isTurkish ? "Tarih ve Saat" : "Date & Time")** | \(dateStr) |\n"
        doc += "| **\(isTurkish ? "Toplam Süre" : "Duration")** | \(metadata.formattedDuration) |\n"
        doc += "| **\(isTurkish ? "Format" : "Format")** | \(metadata.mode.title(isTurkish: isTurkish)) |\n"
        let attendeesStr = metadata.attendees.isEmpty ? (isTurkish ? "Tüm İlgili Paydaşlar" : "All Key Stakeholders") : metadata.attendees.joined(separator: ", ")
        doc += "| **\(isTurkish ? "Katılımcılar" : "Attendees")** | \(attendeesStr) |\n\n"

        doc += "## 1. 🎯 \(isTurkish ? "Toplantı Amacı ve Gündem" : "Meeting Purpose & Agenda")\n\n"
        doc += isTurkish
            ? "Toplantı, belirlenen gündem maddeleri ve devam eden işlerin durumunu değerlendirmek amacıyla gerçekleştirilmiştir.\n\n"
            : "The meeting was convened to review ongoing project deliverables, address operational dependencies, and align on upcoming goals.\n\n"

        doc += "## 2. 💬 \(isTurkish ? "Görüşülen Konular ve Tartışmalar" : "Discussion Points")\n\n"
        if highlights.isEmpty {
            doc += isTurkish ? "- Genel proje gidişatı ve departman hedefleri masaya yatırıldı.\n\n" : "- Reviewed overall timeline and department milestones.\n\n"
        } else {
            for (idx, h) in highlights.enumerated() {
                doc += "**2.\(idx + 1).** \(h)\n\n"
            }
        }

        doc += "## 3. ⚖️ \(isTurkish ? "Alınan Kararlar" : "Decisions Made")\n\n"
        if decisions.isEmpty {
            doc += isTurkish ? "- Mevcut planın aynen sürdürülmesine karar verildi.\n\n" : "- Proceed according to existing schedule.\n\n"
        } else {
            for (idx, d) in decisions.enumerated() {
                doc += "- **K.\(idx + 1):** \(d)\n"
            }
            doc += "\n"
        }

        doc += "## 4. ✅ \(isTurkish ? "Aksiyon Maddeleri ve Sorumlular" : "Action Plan & Assignments")\n\n"
        if actions.isEmpty {
            doc += "- [ ] \(isTurkish ? "Tutanak onaylandıktan sonra paydaşlara dağıtılacak" : "Circulate approved minutes to attendees")\n"
        } else {
            for a in actions {
                doc += "- [ ] \(a)\n"
            }
        }
        doc += "\n"

        doc += "## 5. 📅 \(isTurkish ? "Bir Sonraki Toplantı" : "Next Meeting")\n\n"
        doc += isTurkish
            ? "> Bir sonraki koordinasyon toplantısının tarihi ve saati takvim davetiyle paylaşılacaktır.\n\n"
            : "> Next sync will be scheduled via calendar invite.\n\n"

        if !userNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            doc += "## 📝 \(isTurkish ? "Ek Tutanak Notları" : "Supplementary Notes")\n\n"
            doc += userNotes.trimmingCharacters(in: .whitespacesAndNewlines) + "\n\n"
        }

        doc += appendCollapsibleTranscript(transcript: transcript, isTurkish: isTurkish)
        return doc
    }

    // MARK: - 4. Agile / Sprint Standup
    private func buildAgileStandup(
        metadata: MeetingMetadata,
        transcript: [MeetingTranscriptEntry],
        userNotes: String,
        isTurkish: Bool
    ) -> String {
        let title = metadata.title.isEmpty ? (isTurkish ? "Sprint / Standup Senkronizasyonu" : "Agile Standup Sync") : metadata.title
        let actions = extractActionItems(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)
        let blockers = extractBlockers(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)
        let highlights = extractKeyHighlights(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)

        var doc = ""
        doc += "# 🏃 \(title)\n\n"
        doc += "> ⚡ **\(isTurkish ? "Sprint / Standup Senkronizasyonu" : "Agile Standup Sync")**  \n"
        doc += "> **\(isTurkish ? "Tarih" : "Date"):** \(metadata.date.formatted(date: .abbreviated, time: .shortened)) | **\(isTurkish ? "Süre" : "Time"):** \(metadata.formattedDuration)\n\n"

        doc += "## 🟢 \(isTurkish ? "Tamamlananlar / Dün Ne Yapıldı?" : "What Was Done / Completed")\n\n"
        if highlights.isEmpty {
            doc += isTurkish ? "• Mevcut görevlerde planlanan ilerleme sağlandı.\n\n" : "• Planned progress achieved across assigned sprint tasks.\n\n"
        } else {
            for h in highlights.prefix(3) {
                doc += "• \(h)\n"
            }
            doc += "\n"
        }

        doc += "## 🟡 \(isTurkish ? "Bugün Ne Yapılacak?" : "What's In Progress Today?")\n\n"
        if actions.isEmpty {
            doc += "- [ ] \(isTurkish ? "Sprint görevlerini devam ettir" : "Continue active sprint sprint backlog items")\n\n"
        } else {
            for a in actions.prefix(5) {
                doc += "- [ ] \(a)\n"
            }
            doc += "\n"
        }

        doc += "## 🔴 \(isTurkish ? "Blokeler & Engeller" : "Blockers & Impairments")\n\n"
        if blockers.isEmpty {
            doc += isTurkish ? "• Herhangi bir engel veya teknik bloke bildirilmedi. Yol açık! 🚀\n\n" : "• No blockers reported. Path is clear! 🚀\n\n"
        } else {
            for b in blockers {
                doc += "- 🛑 **\(b)**\n"
            }
            doc += "\n"
        }

        if !userNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            doc += "## 📝 \(isTurkish ? "Hızlı Notlar" : "Standup Scratchpad")\n\n"
            doc += userNotes.trimmingCharacters(in: .whitespacesAndNewlines) + "\n\n"
        }

        doc += appendCollapsibleTranscript(transcript: transcript, isTurkish: isTurkish)
        return doc
    }

    // MARK: - 5. One-on-One Meeting
    private func buildOneOnOne(
        metadata: MeetingMetadata,
        transcript: [MeetingTranscriptEntry],
        userNotes: String,
        isTurkish: Bool
    ) -> String {
        let title = metadata.title.isEmpty ? (isTurkish ? "Birebir (1:1) Görüşme Notları" : "1-on-1 Meeting Notes") : metadata.title
        let actions = extractActionItems(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)
        let highlights = extractKeyHighlights(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)

        var doc = ""
        doc += "# 🤝 \(title)\n\n"
        doc += "> 💬 **\(isTurkish ? "Birebir (1:1) Görüşme" : "1-on-1 Meeting")**  \n"
        doc += "> **\(isTurkish ? "Tarih" : "Date"):** \(metadata.date.formatted(date: .abbreviated, time: .shortened)) | **\(isTurkish ? "Süre" : "Duration"):** \(metadata.formattedDuration)\n\n"

        doc += "## 🌟 \(isTurkish ? "1. Genel Durum & Nabız Yoklama" : "1. Pulse Check & Alignment")\n\n"
        doc += isTurkish
            ? "- İş yükü, motivasyon ve genel çalışma ortamı ele alındı.\n- Mevcut hedeflere yönelik memnuniyet ve odak düzeyi değerlendirildi.\n\n"
            : "- Checked in on motivation, workload balance, and overall bandwidth.\n- Aligned on current quarterly expectations.\n\n"

        doc += "## 🏆 \(isTurkish ? "2. Başarılar & Öne Çıkan Gelişmeler" : "2. Wins & Achievements")\n\n"
        if highlights.isEmpty {
            doc += isTurkish ? "• Son dönem projelerinde başarıyla tamamlanan aşamalar paylaşıldı.\n\n" : "• Recent deliverables and milestones were recognized.\n\n"
        } else {
            for h in highlights.prefix(3) {
                doc += "• \(h)\n"
            }
            doc += "\n"
        }

        doc += "## 🚀 \(isTurkish ? "3. Gelişim Alanları & Destek İhtiyaçları" : "3. Growth & Support Areas")\n\n"
        doc += isTurkish
            ? "- Karşılaşılan zorluklar ve yöneticiden beklenen destek noktaları not edildi.\n- Kariyer gelişimi ve beceri geliştirme fırsatları konuşuldu.\n\n"
            : "- Discussed friction points and where managerial unblocking is needed.\n- Reviewed skill development and long-term career goals.\n\n"

        doc += "## ✅ \(isTurkish ? "4. Kararlaştırılan Aksiyon Maddeleri" : "4. Mutual Commitments & Action Items")\n\n"
        if actions.isEmpty {
            doc += "- [ ] \(isTurkish ? "Bir sonraki 1:1 görüşmeye kadar belirlenen maddeleri takip et" : "Follow up on discussion items before next 1:1")\n"
        } else {
            for a in actions {
                doc += "- [ ] \(a)\n"
            }
        }
        doc += "\n"

        if !userNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            doc += "## 📝 \(isTurkish ? "Özel Notlar" : "Private Notes")\n\n"
            doc += userNotes.trimmingCharacters(in: .whitespacesAndNewlines) + "\n\n"
        }

        doc += appendCollapsibleTranscript(transcript: transcript, isTurkish: isTurkish)
        return doc
    }

    // MARK: - 6. Brainstorming & Decisions
    private func buildBrainstorming(
        metadata: MeetingMetadata,
        transcript: [MeetingTranscriptEntry],
        userNotes: String,
        isTurkish: Bool
    ) -> String {
        let title = metadata.title.isEmpty ? (isTurkish ? "Beyin Fırtınası & Fikir Çalıştayı" : "Brainstorming & Strategy Canvas") : metadata.title
        let highlights = extractKeyHighlights(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)
        let decisions = extractKeyDecisions(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)
        let actions = extractActionItems(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)

        var doc = ""
        doc += "# 💡 \(title)\n\n"
        doc += "> 🧠 **\(isTurkish ? "Beyin Fırtınası & Fikir Çalıştayı" : "Brainstorming & Strategy Canvas")**  \n"
        doc += "> **\(isTurkish ? "Tarih" : "Date"):** \(metadata.date.formatted(date: .abbreviated, time: .shortened)) | **\(isTurkish ? "Fikir Seansı" : "Brainstorm Session")**\n\n"

        doc += "## 🎯 \(isTurkish ? "Ele Alınan Problem / Odak Noktası" : "Problem Statement & Opportunity")\n\n"
        doc += isTurkish
            ? "Mevcut süreci optimize etmek ve yenilikçi çözümler üretmek amacıyla tüm alternatifler masaya yatırıldı.\n\n"
            : "Explored creative pathways and technical options to address the primary problem statement.\n\n"

        doc += "## 💡 \(isTurkish ? "Masaya Yatırılan Fikirler ve Öneriler" : "Ideas Explored")\n\n"
        if highlights.isEmpty {
            doc += isTurkish ? "• Kullanıcı deneyimini güçlendirecek farklı modeller üzerinde duruldu.\n\n" : "• Evaluated alternative architecture and UX pathways.\n\n"
        } else {
            for h in highlights {
                doc += "• 💡 **Fikir:** \(h)\n"
            }
            doc += "\n"
        }

        doc += "## ⚖️ \(isTurkish ? "Seçilen Öncelikli Yaklaşım & Karar" : "Selected Solution & Rationale")\n\n"
        if decisions.isEmpty {
            doc += isTurkish
                ? "- Fikirlerin fizibilitesi değerlendirildikten sonra nihai karar verilecek.\n\n"
                : "- Feasibility evaluation will determine the final route.\n\n"
        } else {
            for d in decisions {
                doc += "🏆 **\(d)**\n"
            }
            doc += "\n"
        }

        doc += "## 🚀 \(isTurkish ? "Sonraki Adımlar" : "Next Steps & Experiments")\n\n"
        if actions.isEmpty {
            doc += "- [ ] \(isTurkish ? "Seçilen fikir için hızlı prototip / PoC hazırla" : "Build rapid prototype / PoC for winning idea")\n"
        } else {
            for a in actions {
                doc += "- [ ] \(a)\n"
            }
        }
        doc += "\n"

        if !userNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            doc += "## 📝 \(isTurkish ? "Beyin Fırtınası Karalamaları" : "Ideation Scratchpad")\n\n"
            doc += userNotes.trimmingCharacters(in: .whitespacesAndNewlines) + "\n\n"
        }

        doc += appendCollapsibleTranscript(transcript: transcript, isTurkish: isTurkish)
        return doc
    }

    // MARK: - 7. Follow-Up Email
    private func buildFollowUpEmail(
        metadata: MeetingMetadata,
        transcript: [MeetingTranscriptEntry],
        userNotes: String,
        isTurkish: Bool
    ) -> String {
        let title = metadata.title.isEmpty ? (isTurkish ? "Toplantı Takibi" : "Meeting Follow-up") : metadata.title
        let dateStr = metadata.date.formatted(date: .abbreviated, time: .shortened)
        let actions = extractActionItems(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)
        let decisions = extractKeyDecisions(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)
        let highlights = extractKeyHighlights(transcript: transcript, userNotes: userNotes, isTurkish: isTurkish)

        var email = ""
        email += "## ✉️ \(isTurkish ? "Hazır Takip E-postası Taslağı" : "Follow-Up Email Draft")\n\n"
        email += "**\(isTurkish ? "Konu" : "Subject"):** [\(isTurkish ? "Özet & Aksiyonlar" : "Summary & Actions")] \(title) — \(dateStr)\n\n"
        email += "---\n\n"

        if isTurkish {
            email += "Merhaba Ekip,\n\n"
            email += "Bugünkü **\(title)** toplantımız için herkese teşekkür ederim. Toplantıda ele aldığımız temel konular ve mutabakata vardığımız kararlar aşağıda özetlenmiştir:\n\n"

            if !highlights.isEmpty {
                email += "### 📌 Öne Çıkan Konular:\n"
                for h in highlights.prefix(3) {
                    email += "• \(h)\n"
                }
                email += "\n"
            }

            if !decisions.isEmpty {
                email += "### ⚖️ Alınan Kararlar:\n"
                for d in decisions {
                    email += "• \(d)\n"
                }
                email += "\n"
            }

            email += "### ✅ Aksiyon Maddeleri ve Sorumluluklar:\n"
            if actions.isEmpty {
                email += "- [ ] İlgili konuların takibini sürdürelim.\n"
            } else {
                for a in actions {
                    email += "- [ ] \(a)\n"
                }
            }
            email += "\n"

            email += "Herhangi bir ekleme veya sorunuz olursa lütfen iletmekten çekinmeyin.\n\n"
            email += "İyi çalışmalar,\n"
            email += "**NotesMy ile oluşturuldu**\n"
        } else {
            email += "Hi Team,\n\n"
            email += "Thank you for your time during today's **\(title)** sync. Below is a concise recap of our discussions, confirmed decisions, and assigned deliverables:\n\n"

            if !highlights.isEmpty {
                email += "### 📌 Key Highlights:\n"
                for h in highlights.prefix(3) {
                    email += "• \(h)\n"
                }
                email += "\n"
            }

            if !decisions.isEmpty {
                email += "### ⚖️ Agreed Decisions:\n"
                for d in decisions {
                    email += "• \(d)\n"
                }
                email += "\n"
            }

            email += "### ✅ Action Items & Owners:\n"
            if actions.isEmpty {
                email += "- [ ] Follow up on identified initiatives.\n"
            } else {
                for a in actions {
                    email += "- [ ] \(a)\n"
                }
            }
            email += "\n"

            email += "Please let me know if there are any adjustments needed.\n\n"
            email += "Best regards,\n"
            email += "**Generated with NotesMy Meeting Studio**\n"
        }

        return email
    }

    // MARK: - 8. Full Transcript
    private func buildFullTranscriptView(
        metadata: MeetingMetadata,
        transcript: [MeetingTranscriptEntry],
        userNotes: String,
        isTurkish: Bool
    ) -> String {
        let title = metadata.title.isEmpty ? (isTurkish ? "Toplantı Transkripti" : "Meeting Transcript") : metadata.title
        var doc = "# 🎙️ \(title)\n\n"
        doc += "> **\(isTurkish ? "Tarih" : "Date"):** \(metadata.date.formatted(date: .complete, time: .shortened)) | **\(isTurkish ? "Süre" : "Duration"):** \(metadata.formattedDuration) | **\(isTurkish ? "Mod" : "Mode"):** \(metadata.mode.title(isTurkish: isTurkish))\n\n"

        if !userNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            doc += "## 📝 \(isTurkish ? "Kullanıcı Notları" : "Meeting Notes")\n\n"
            doc += userNotes.trimmingCharacters(in: .whitespacesAndNewlines) + "\n\n"
            doc += "---\n\n"
        }

        doc += "## 💬 \(isTurkish ? "Zaman Damgalı Konuşma Dökümü" : "Chronological Transcript")\n\n"
        if transcript.isEmpty {
            doc += isTurkish
                ? "*Bu toplantı için henüz kaydedilmiş ses dökümü bulunmuyor.*\n"
                : "*No transcribed audio recorded for this meeting session.*\n"
        } else {
            for entry in transcript {
                let badge = entry.speaker.shortLabel(isTurkish: isTurkish)
                doc += "`\(entry.formattedTime)` **[\(badge)]**: \(entry.text)\n\n"
            }
        }

        return doc
    }

    // MARK: - Helper: Collapsible Transcript Block
    private func appendCollapsibleTranscript(transcript: [MeetingTranscriptEntry], isTurkish: Bool) -> String {
        guard !transcript.isEmpty else { return "" }
        var res = "---\n\n"
        let summaryLabel = isTurkish ? "🎙️ Tam Konuşma Dökümü (Tıklayarak İnceleyin)" : "🎙️ Full Audio Transcript (Click to Expand)"
        res += "<details>\n<summary><strong>\(summaryLabel)</strong></summary>\n\n"
        for entry in transcript {
            let badge = entry.speaker.shortLabel(isTurkish: isTurkish)
            res += "- `\(entry.formattedTime)` **[\(badge)]**: \(entry.text)\n"
        }
        res += "\n</details>\n"
        return res
    }

    // MARK: - Smart Extraction Helpers
    public func extractActionItems(transcript: [MeetingTranscriptEntry], userNotes: String, isTurkish: Bool) -> [String] {
        var items: [String] = []

        let actionKeywords = [
            "will", "need to", "must", "todo", "action", "task", "follow up",
            "send", "prepare", "finish", "review", "deliver", "deploy", "schedule", "fix",
            "yapacak", "yapacağım", "hazırla", "gönder", "tamamla", "gözden geçir",
            "ilgilen", "düzenle", "teslim", "pazartesiye", "haftaya", "hallederim"
        ]

        // 1. From user scratchpad
        let noteLines = userNotes.components(separatedBy: .newlines)
        for line in noteLines {
            let trim = line.trimmingCharacters(in: .whitespaces)
            if trim.hasPrefix("- [ ]") || trim.hasPrefix("- [x]") {
                let text = trim.replacingOccurrences(of: "- [ ]", with: "").replacingOccurrences(of: "- [x]", with: "").trimmingCharacters(in: .whitespaces)
                if !text.isEmpty && !items.contains(text) { items.append(text) }
            } else if trim.hasPrefix("- ") || trim.hasPrefix("* ") {
                let text = String(trim.dropFirst(2))
                if !text.isEmpty && !items.contains(text) { items.append(text) }
            }
        }

        // 2. From speech transcript utterances
        for entry in transcript {
            let lower = entry.text.lowercased()
            let hasAction = actionKeywords.contains { lower.contains($0) }
            if hasAction {
                let speakerPrefix = entry.speaker.shortLabel(isTurkish: isTurkish)
                let candidate = "**[\(speakerPrefix)]**: \(entry.text)"
                if !items.contains(where: { $0.contains(entry.text) }) {
                    items.append(candidate)
                }
            }
        }

        return items
    }

    public func extractKeyDecisions(transcript: [MeetingTranscriptEntry], userNotes: String, isTurkish: Bool) -> [String] {
        var decisions: [String] = []
        let decisionKeywords = [
            "decided", "agreed", "finalized", "approved", "consensus", "we will go with", "selected",
            "karar verdik", "karar aldık", "kararlaştırdık", "mutabık kaldık", "onaylandı", "onayladık", "seçtik", "karar verildi", "sonuç olarak", "netleştirdik", "belirledik"
        ]

        for entry in transcript {
            let lower = entry.text.lowercased()
            if decisionKeywords.contains(where: { lower.contains($0) }) {
                if !decisions.contains(entry.text) {
                    decisions.append(entry.text)
                }
            }
        }

        for line in userNotes.components(separatedBy: .newlines) {
            let lower = line.lowercased()
            if decisionKeywords.contains(where: { lower.contains($0) }) {
                let clean = line.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "-", with: "").trimmingCharacters(in: .whitespaces)
                if !clean.isEmpty && !decisions.contains(clean) {
                    decisions.append(clean)
                }
            }
        }

        return decisions
    }

    public func extractBlockers(transcript: [MeetingTranscriptEntry], userNotes: String, isTurkish: Bool) -> [String] {
        var blockers: [String] = []
        let blockerKeywords = [
            "blocker", "blocked", "impediment", "stuck", "risk", "delay", "waiting for", "bug",
            "bloke", "engel", "takıldık", "sorun", "bekliyoruz", "gecikme", "riskli", "hata"
        ]

        for entry in transcript {
            let lower = entry.text.lowercased()
            if blockerKeywords.contains(where: { lower.contains($0) }) {
                if !blockers.contains(entry.text) {
                    blockers.append(entry.text)
                }
            }
        }

        return blockers
    }

    public func extractKeyHighlights(transcript: [MeetingTranscriptEntry], userNotes: String, isTurkish: Bool) -> [String] {
        var highlights: [String] = []

        // Tokenize significant sentences
        let allText = transcript.map { $0.text }.joined(separator: ". ")
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = allText

        tokenizer.enumerateTokens(in: allText.startIndex..<allText.endIndex) { range, _ in
            let s = String(allText[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            if s.count > 15 && s.count < 140 {
                highlights.append(s)
            }
            return highlights.count < 5
        }

        if highlights.isEmpty && !transcript.isEmpty {
            for entry in transcript.prefix(4) {
                highlights.append(entry.text)
            }
        }

        return highlights
    }

    private func escapeMarkdown(_ str: String) -> String {
        return str.replacingOccurrences(of: "|", with: "\\|")
    }
}
