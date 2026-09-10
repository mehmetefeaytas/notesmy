import Testing
import Foundation
@testable import NotesMy

@Suite("Meeting Recording & AI Second Brain Intelligence Tests")
struct MeetingTests {

    @Test("Meeting Models, Speakers and Modes")
    func testMeetingModelsAndSpeakers() {
        let speakerYou = MeetingSpeaker.you
        let speakerRemote = MeetingSpeaker.remote
        let speakerRoom = MeetingSpeaker.roomSpeaker(2)
        let speakerCustom = MeetingSpeaker.custom("Ahmet")

        #expect(speakerYou.shortLabel(isTurkish: true) == "Sen")
        #expect(speakerYou.shortLabel(isTurkish: false) == "You")
        #expect(speakerRemote.shortLabel(isTurkish: true) == "Katılımcılar")
        #expect(speakerRemote.shortLabel(isTurkish: false) == "Remote")
        #expect(speakerRoom.shortLabel(isTurkish: true) == "K2")
        #expect(speakerRoom.shortLabel(isTurkish: false) == "S2")
        #expect(speakerCustom.shortLabel(isTurkish: true) == "Ahmet")

        let onlineMode = MeetingMode.online
        let inPersonMode = MeetingMode.inPerson
        #expect(onlineMode.title(isTurkish: true).contains("Online"))
        #expect(inPersonMode.title(isTurkish: true).contains("Yüz Yüze"))
        #expect(!onlineMode.subtitle(isTurkish: false).isEmpty)
    }

    @Test("Meeting Metadata and Duration formatting")
    func testMeetingMetadataDuration() {
        let meta1 = MeetingMetadata(
            title: "Sprint Sync",
            duration: 75, // 1 min 15 sec
            mode: .online,
            attendees: ["Efe", "Ahmet"]
        )
        #expect(meta1.formattedDuration == "01:15")
        #expect(meta1.attendees.count == 2)

        let meta2 = MeetingMetadata(
            title: "Q3 Strategy Planning",
            duration: 3725, // 1 hour, 2 min, 5 sec
            mode: .inPerson,
            attendees: ["Team Lead", "Product Manager", "CTO"]
        )
        #expect(meta2.formattedDuration == "01:02:05")
    }

    @Test("Meeting AI - Executive Summary Template")
    func testExecutiveSummaryTemplate() {
        let meta = MeetingMetadata(
            title: "Q4 Bütçe ve Ürün Planlama",
            duration: 1800,
            mode: .online,
            attendees: ["Mehmet", "Zeynep"]
        )

        let transcript = [
            MeetingTranscriptEntry(timestamp: 10, speaker: .you, text: "Toplantıya hoş geldiniz. Bugün bütçe dağılımını konuşacağız."),
            MeetingTranscriptEntry(timestamp: 45, speaker: .remote, text: "Pazarlama bütçesini %20 artırmaya karar verdik."),
            MeetingTranscriptEntry(timestamp: 90, speaker: .you, text: "Tamam, ben mali tabloyu cuma gününe kadar hazırlayacağım.")
        ]

        let userNotes = "- [ ] CFO'dan nihai onay al\n- Sunum slaytlarını güncelle"

        let summaryTR = MeetingAIService.shared.generateMeetingNote(
            metadata: meta,
            transcriptEntries: transcript,
            userNotes: userNotes,
            template: .executiveSummary,
            isTurkish: true
        )

        #expect(summaryTR.contains("Q4 Bütçe ve Ürün Planlama"))
        #expect(summaryTR.contains("Yönetici Özeti"))
        #expect(summaryTR.contains("Alınan Temel Kararlar"))
        #expect(summaryTR.contains("karar verdik"))
        #expect(summaryTR.contains("Öncelikli Aksiyonlar"))
        #expect(summaryTR.contains("Toplantı Sırasında Alınan Notlar"))
        #expect(summaryTR.contains("Tam Konuşma Dökümü"))
    }

    @Test("Meeting AI - Action Items Template")
    func testActionItemsTemplate() {
        let meta = MeetingMetadata(
            title: "Release Checklist Sync",
            duration: 600,
            mode: .online,
            attendees: ["Dev", "QA"]
        )

        let transcript = [
            MeetingTranscriptEntry(timestamp: 15, speaker: .you, text: "I will deploy the backend patch by tomorrow."),
            MeetingTranscriptEntry(timestamp: 30, speaker: .remote, text: "QA team must finish smoke tests by 3 PM.")
        ]

        let notes = "- [ ] Notify DevOps team before merge\n- [ ] Update changelog"

        let actions = MeetingAIService.shared.generateMeetingNote(
            metadata: meta,
            transcriptEntries: transcript,
            userNotes: notes,
            template: .actionItems,
            isTurkish: false
        )

        #expect(actions.contains("Task Checklist") || actions.contains("Action Items"))
        #expect(actions.contains("- [ ]"))
        #expect(actions.contains("Notify DevOps team before merge"))
        #expect(actions.contains("Update changelog"))
    }

    @Test("Meeting AI - Formal Minutes of Meeting (MoM)")
    func testFormalMoMTemplate() {
        let meta = MeetingMetadata(
            title: "Yönetim Kurulu Senkronizasyonu",
            duration: 2400,
            mode: .online,
            attendees: ["Ali", "Ayşe", "Fatma"]
        )

        let transcript = [
            MeetingTranscriptEntry(timestamp: 20, speaker: .you, text: "Gündemin ilk maddesi olarak yeni ofis lokasyonunu seçtik."),
            MeetingTranscriptEntry(timestamp: 120, speaker: .remote, text: "Bütçe aşımı için onaylandı.")
        ]

        let mom = MeetingAIService.shared.generateMeetingNote(
            metadata: meta,
            transcriptEntries: transcript,
            userNotes: "Kira sözleşmesi incelenecek",
            template: .formalMoM,
            isTurkish: true
        )

        #expect(mom.contains("Resmi Toplantı Tutanağı"))
        #expect(mom.contains("Toplantı Kimlik Bilgileri"))
        #expect(mom.contains("Ali, Ayşe, Fatma"))
        #expect(mom.contains("Toplantı Amacı ve Gündem"))
        #expect(mom.contains("Alınan Kararlar"))
    }

    @Test("Meeting AI - Agile Standup Template")
    func testAgileStandupTemplate() {
        let meta = MeetingMetadata(
            title: "Sprint 42 Daily Standup",
            duration: 900,
            mode: .online,
            attendees: ["Frontend", "Backend"]
        )

        let transcript = [
            MeetingTranscriptEntry(timestamp: 10, speaker: .you, text: "I finished the export module yesterday."),
            MeetingTranscriptEntry(timestamp: 25, speaker: .remote, text: "We are stuck waiting for auth server fix, it is a blocker.")
        ]

        let standup = MeetingAIService.shared.generateMeetingNote(
            metadata: meta,
            transcriptEntries: transcript,
            userNotes: "",
            template: .agileStandup,
            isTurkish: false
        )

        #expect(standup.contains("Sprint / Standup Sync") || standup.contains("Agile Standup"))
        #expect(standup.contains("What Was Done"))
        #expect(standup.contains("Blockers"))
        #expect(standup.contains("blocker") || standup.contains("waiting for"))
    }

    @Test("Meeting AI - 1-on-1 Meeting Template")
    func testOneOnOneTemplate() {
        let meta = MeetingMetadata(
            title: "Kariyer ve Performans Görüşmesi",
            duration: 1800,
            mode: .inPerson,
            attendees: ["Yönetici", "Mühendis"]
        )

        let transcript = [
            MeetingTranscriptEntry(timestamp: 60, speaker: .you, text: "Bu çeyrekte proje hedeflerini tamamladık."),
            MeetingTranscriptEntry(timestamp: 120, speaker: .remote, text: "Seni gelecek dönem kıdemli pozisyona aday göstereceğim.")
        ]

        let oneOnOne = MeetingAIService.shared.generateMeetingNote(
            metadata: meta,
            transcriptEntries: transcript,
            userNotes: "Eğitim bütçesi talep edilecek",
            template: .oneOnOne,
            isTurkish: true
        )

        #expect(oneOnOne.contains("Birebir (1:1) Görüşme"))
        #expect(oneOnOne.contains("Genel Durum & Nabız Yoklama"))
        #expect(oneOnOne.contains("Başarılar & Öne Çıkan Gelişmeler"))
        #expect(oneOnOne.contains("Gelişim Alanları & Destek"))
    }

    @Test("Meeting AI - Brainstorming Template")
    func testBrainstormingTemplate() {
        let meta = MeetingMetadata(
            title: "Yapay Zeka Özellik Fikirleri",
            duration: 1200,
            mode: .online,
            attendees: ["Product Team"]
        )

        let transcript = [
            MeetingTranscriptEntry(timestamp: 30, speaker: .you, text: "Fikir olarak ses kaydı ve toplantı transkripsiyonu ekleyelim."),
            MeetingTranscriptEntry(timestamp: 90, speaker: .remote, text: "Harika fikir, bu çözümü seçtik.")
        ]

        let brainstorm = MeetingAIService.shared.generateMeetingNote(
            metadata: meta,
            transcriptEntries: transcript,
            userNotes: "Kullanıcılar çok sevecek",
            template: .brainstorming,
            isTurkish: true
        )

        #expect(brainstorm.contains("Beyin Fırtınası & Fikir Çalıştayı"))
        #expect(brainstorm.contains("Masaya Yatırılan Fikirler"))
        #expect(brainstorm.contains("Seçilen Öncelikli Yaklaşım"))
    }

    @Test("Meeting AI - Follow-Up Email Draft")
    func testFollowUpEmailTemplate() {
        let meta = MeetingMetadata(
            title: "Client Project Kickoff",
            duration: 1500,
            mode: .online,
            attendees: ["Client Rep", "Project Manager"]
        )

        let transcript = [
            MeetingTranscriptEntry(timestamp: 20, speaker: .you, text: "We decided to start with the mobile prototype."),
            MeetingTranscriptEntry(timestamp: 60, speaker: .remote, text: "I will send the branding assets by Friday.")
        ]

        let email = MeetingAIService.shared.generateMeetingNote(
            metadata: meta,
            transcriptEntries: transcript,
            userNotes: "Contact: info@example.com",
            template: .followUpEmail,
            isTurkish: false
        )

        #expect(email.contains("Subject:") || email.contains("Konu:"))
        #expect(email.contains("Hi Team") || email.contains("Merhaba"))
        #expect(email.contains("Key Highlights") || email.contains("Öne Çıkan"))
        #expect(email.contains("Agreed Decisions") || email.contains("Alınan Kararlar"))
        #expect(email.contains("Action Items") || email.contains("Aksiyon"))
        #expect(email.contains("Best regards") || email.contains("İyi çalışmalar"))
    }

    @Test("Meeting AI - Full Transcript View")
    func testFullTranscriptView() {
        let meta = MeetingMetadata(
            title: "Architecture Review",
            duration: 600,
            mode: .online
        )

        let transcript = [
            MeetingTranscriptEntry(timestamp: 12, speaker: .you, text: "Let's inspect ScreenCaptureKit audio tap."),
            MeetingTranscriptEntry(timestamp: 45, speaker: .remote, text: "Dual audio level meters are working smoothly.")
        ]

        let view = MeetingAIService.shared.generateMeetingNote(
            metadata: meta,
            transcriptEntries: transcript,
            userNotes: "Tested on macOS 14 & 15",
            template: .fullTranscript,
            isTurkish: false
        )

        #expect(view.contains("00:12"))
        #expect(view.contains("00:45"))
        #expect(view.contains("ScreenCaptureKit"))
        #expect(view.contains("Dual audio level meters"))
    }

    @Test("Action item and Decision keyword extraction")
    func testKeywordExtraction() {
        let transcript = [
            MeetingTranscriptEntry(timestamp: 10, speaker: .you, text: "Ben sunumu hazırlayacağım."),
            MeetingTranscriptEntry(timestamp: 20, speaker: .remote, text: "Proje planında mutabık kaldık."),
            MeetingTranscriptEntry(timestamp: 30, speaker: .remote, text: "Bu servis için bir engel var, API yanıt vermiyor.")
        ]

        let actions = MeetingAIService.shared.extractActionItems(transcript: transcript, userNotes: "- [ ] Testleri çalıştır", isTurkish: true)
        let decisions = MeetingAIService.shared.extractKeyDecisions(transcript: transcript, userNotes: "", isTurkish: true)
        let blockers = MeetingAIService.shared.extractBlockers(transcript: transcript, userNotes: "", isTurkish: true)

        #expect(actions.contains(where: { $0.contains("hazırlayacağım") }))
        #expect(actions.contains(where: { $0.contains("Testleri çalıştır") }))
        #expect(decisions.contains(where: { $0.contains("mutabık kaldık") }))
        #expect(blockers.contains(where: { $0.contains("engel") }))
    }

    @Test("Meeting Recording Service State and Default Setup")
    @MainActor
    func testMeetingRecordingServiceState() {
        let service = MeetingRecordingService.shared
        #expect(service.isRecording == false)
        #expect(service.isPaused == false)
        #expect(service.selectedMode == .online)

        service.pauseMeeting()
        // If not recording, pause shouldn't change isPaused to true
        #expect(service.isPaused == false)
    }
}
