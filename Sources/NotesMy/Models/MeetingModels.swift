import Foundation

/// Type of speaker detected in meeting audio
public enum MeetingSpeaker: Codable, Equatable, Hashable, Sendable {
    case you                // Local user via Microphone
    case remote             // Remote participants via System Audio (Zoom, Teams, Meet)
    case roomSpeaker(Int)   // In-person detected room speakers
    case custom(String)     // User-customized speaker name

    public func displayName(isTurkish: Bool) -> String {
        switch self {
        case .you:
            return isTR(isTurkish) ? "Sen (Mikrofon)" : "You (Microphone)"
        case .remote:
            return isTR(isTurkish) ? "Toplantı (Ekran / Zoom / Teams)" : "Meeting (Screen / Remote)"
        case .roomSpeaker(let idx):
            return isTR(isTurkish) ? "Konuşmacı \(idx)" : "Speaker \(idx)"
        case .custom(let name):
            return name
        }
    }

    @MainActor
    public var displayName: String {
        displayName(isTurkish: LocalizationService.shared.language == .turkish)
    }

    public func shortLabel(isTurkish: Bool) -> String {
        switch self {
        case .you:
            return isTR(isTurkish) ? "Sen" : "You"
        case .remote:
            return isTR(isTurkish) ? "Katılımcılar" : "Remote"
        case .roomSpeaker(let idx):
            return isTR(isTurkish) ? "K\(idx)" : "S\(idx)"
        case .custom(let name):
            return name
        }
    }

    @MainActor
    public var shortLabel: String {
        shortLabel(isTurkish: LocalizationService.shared.language == .turkish)
    }

    public var icon: String {
        switch self {
        case .you: return "person.fill"
        case .remote: return "person.2.wave.2.fill"
        case .roomSpeaker: return "mic.fill"
        case .custom: return "person.crop.circle.fill"
        }
    }

    private func isTR(_ val: Bool) -> Bool { val }
}

/// A single timestamped speech utterance in a meeting
public struct MeetingTranscriptEntry: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var timestamp: TimeInterval // Elapsed seconds from start of meeting
    public var speaker: MeetingSpeaker
    public var text: String
    public var isFinal: Bool

    public init(
        id: UUID = UUID(),
        timestamp: TimeInterval,
        speaker: MeetingSpeaker,
        text: String,
        isFinal: Bool = true
    ) {
        self.id = id
        self.timestamp = timestamp
        self.speaker = speaker
        self.text = text
        self.isFinal = isFinal
    }

    public var formattedTime: String {
        let totalSeconds = Int(timestamp)
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

/// Meeting recording capture mode
public enum MeetingMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case online     = "online"      // Mic (You) + Screen/System Audio (Zoom/Teams/Meet)
    case inPerson   = "in_person"   // Room microphone optimized for in-person meetings
    case systemOnly = "system_only" // Screen & system audio only (Webinar, podcast, video)
    case micOnly    = "mic_only"    // Local microphone only (Dictation, memo)

    public var id: String { rawValue }

    public func title(isTurkish: Bool) -> String {
        switch self {
        case .online:
            return isTurkish ? "Online Toplantı (Zoom, Teams, Meet)" : "Online Meeting (Zoom, Teams, Meet)"
        case .inPerson:
            return isTurkish ? "Yüz Yüze Toplantı" : "In-Person Meeting"
        case .systemOnly:
            return isTurkish ? "Sadece Ekran/Sistem Sesi" : "Screen Audio Only (Webinar/Video)"
        case .micOnly:
            return isTurkish ? "Sadece Mikrofon" : "Microphone Only (Voice Memo)"
        }
    }

    @MainActor
    public var title: String {
        title(isTurkish: LocalizationService.shared.language == .turkish)
    }

    public func subtitle(isTurkish: Bool) -> String {
        switch self {
        case .online:
            return isTurkish ? "Mikrofon (Sen) + Ekran/Hoparlör (Katılımcılar) çift kanallı yakalama" : "Dual capture: Mic (You) + System audio (Zoom/Teams/Meet)"
        case .inPerson:
            return isTurkish ? "Tüm odayı dinleyen optimize edilmiş ortam kaydı" : "High-sensitivity microphone for conference rooms"
        case .systemOnly:
            return isTurkish ? "Webinar, podcast veya video konferans izlerken ses dökümü" : "Transcribe audio from webinars, videos, or presentations"
        case .micOnly:
            return isTurkish ? "Bireysel sesli not, fikir geliştirme ve dikte" : "Individual speech-to-text dictation and voice memo"
        }
    }

    @MainActor
    public var subtitle: String {
        subtitle(isTurkish: LocalizationService.shared.language == .turkish)
    }

    public var icon: String {
        switch self {
        case .online: return "video.fill"
        case .inPerson: return "person.3.sequence.fill"
        case .systemOnly: return "speaker.wave.3.fill"
        case .micOnly: return "mic.fill"
        }
    }
}

/// Supported AI Second Brain Meeting Synthesis Templates
public enum MeetingTemplate: String, CaseIterable, Identifiable, Codable, Sendable {
    case executiveSummary = "summary"
    case actionItems      = "actions"
    case formalMoM        = "mom"
    case agileStandup     = "standup"
    case oneOnOne         = "one_on_one"
    case brainstorming    = "brainstorming"
    case followUpEmail    = "email"
    case fullTranscript   = "transcript"

    public var id: String { rawValue }

    public func title(isTurkish: Bool) -> String {
        switch self {
        case .executiveSummary:
            return isTurkish ? "Yönetici Özeti" : "Executive Summary"
        case .actionItems:
            return isTurkish ? "Aksiyon Maddeleri" : "Action Items"
        case .formalMoM:
            return isTurkish ? "Resmi Tutanak (MoM)" : "Minutes of Meeting"
        case .agileStandup:
            return isTurkish ? "Sprint / Standup" : "Agile Standup"
        case .oneOnOne:
            return isTurkish ? "Birebir (1:1)" : "1-on-1 Meeting"
        case .brainstorming:
            return isTurkish ? "Beyin Fırtınası" : "Brainstorming"
        case .followUpEmail:
            return isTurkish ? "Takip E-postası" : "Follow-Up Email"
        case .fullTranscript:
            return isTurkish ? "Tam Transkript" : "Full Transcript"
        }
    }

    @MainActor
    public var title: String {
        title(isTurkish: LocalizationService.shared.language == .turkish)
    }

    public var icon: String {
        switch self {
        case .executiveSummary: return "sparkles"
        case .actionItems: return "checklist"
        case .formalMoM: return "doc.text.fill"
        case .agileStandup: return "figure.run"
        case .oneOnOne: return "person.2.fill"
        case .brainstorming: return "lightbulb.fill"
        case .followUpEmail: return "envelope.fill"
        case .fullTranscript: return "waveform.and.magnifyingglass"
        }
    }
}

/// Metadata captured during a meeting
public struct MeetingMetadata: Codable, Equatable, Sendable {
    public var title: String
    public var date: Date
    public var duration: TimeInterval
    public var mode: MeetingMode
    public var attendees: [String]
    public var audioFileURL: URL?

    public init(
        title: String,
        date: Date = Date(),
        duration: TimeInterval,
        mode: MeetingMode,
        attendees: [String] = [],
        audioFileURL: URL? = nil
    ) {
        self.title = title
        self.date = date
        self.duration = duration
        self.mode = mode
        self.attendees = attendees
        self.audioFileURL = audioFileURL
    }

    public var formattedDuration: String {
        let total = Int(duration)
        let hours = total / 3600
        let mins = (total % 3600) / 60
        let secs = total % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, mins, secs)
        } else {
            return String(format: "%02d:%02d", mins, secs)
        }
    }
}
