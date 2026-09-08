import Foundation
import SwiftUI

public enum AppLanguage: String, Codable, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case turkish = "tr"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        }
    }
}

@MainActor
public final class LocalizationService: ObservableObject {
    public static let shared = LocalizationService()

    @Published public var language: AppLanguage = .turkish {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "NotesMyLanguage")
        }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: "NotesMyLanguage"),
           let lang = AppLanguage(rawValue: saved) {
            self.language = lang
        } else {
            // Default to Turkish if system is Turkish, else English
            let pref = Locale.preferredLanguages.first ?? "en"
            self.language = pref.hasPrefix("tr") ? .turkish : .english
        }
    }

    public func text(_ key: LocalizationKey) -> String {
        switch language {
        case .english: return key.en
        case .turkish: return key.tr
        }
    }
}

public enum LocalizationKey {
    case appName
    case newNote
    case quickCapture
    case allNotes
    case stickyBoard
    case archive
    case favorites
    case pinned
    case settings
    case searchPlaceholder
    case filterActive
    case filterArchived
    case filterAll
    case wordCount(Int, Int)
    case noteTitlePlaceholder
    case emptyNote
    case deleteConfirm
    case undo
    case summarize
    case extractTasks
    case cleanMessyNote
    case smartTitle
    case autoCategorize
    case speechRecord
    case speechRecording
    case speechStop
    case captureScreen
    case ocrExtract
    case addReminder
    case sendToAppleNotes
    case sendToReminders
    case boardTitle
    case boardHint
    case semanticSearch
    case appearanceTab
    case generalTab
    case aiSpeechTab
    case shortcutsTab

    public var en: String {
        switch self {
        case .appName: return "NotesMy"
        case .newNote: return "New Note"
        case .quickCapture: return "Quick Capture"
        case .allNotes: return "All Notes"
        case .stickyBoard: return "Sticky Board"
        case .archive: return "Archive"
        case .favorites: return "Favorites"
        case .pinned: return "Pinned"
        case .settings: return "Settings"
        case .searchPlaceholder: return "Search notes, tags, transcripts..."
        case .filterActive: return "Active"
        case .filterArchived: return "Archived"
        case .filterAll: return "All"
        case .wordCount(let w, let c): return "\(w) words · \(c) chars"
        case .noteTitlePlaceholder: return "Note Title..."
        case .emptyNote: return "Empty note..."
        case .deleteConfirm: return "Delete?"
        case .undo: return "Undo"
        case .summarize: return "Summarize Note"
        case .extractTasks: return "Extract Action Items"
        case .cleanMessyNote: return "Format & Organize Messy Note"
        case .smartTitle: return "Suggest Smart Title"
        case .autoCategorize: return "Auto-Categorize Note"
        case .speechRecord: return "Voice Note & Transcribe"
        case .speechRecording: return "Listening..."
        case .speechStop: return "Stop Recording"
        case .captureScreen: return "Capture Screenshot to Note"
        case .ocrExtract: return "Extract Text from Images (OCR)"
        case .addReminder: return "Set Reminder Alert"
        case .sendToAppleNotes: return "Export to Apple Notes"
        case .sendToReminders: return "Export to Reminders"
        case .boardTitle: return "Sticky Board Canvas"
        case .boardHint: return "Drag notes freely across the board"
        case .semanticSearch: return "Semantic Search"
        case .appearanceTab: return "Appearance"
        case .generalTab: return "General"
        case .aiSpeechTab: return "AI & Voice"
        case .shortcutsTab: return "Shortcuts"
        }
    }

    public var tr: String {
        switch self {
        case .appName: return "NotesMy"
        case .newNote: return "Yeni Not"
        case .quickCapture: return "Hızlı Yakala"
        case .allNotes: return "Tüm Notlar"
        case .stickyBoard: return "Mantar Pano"
        case .archive: return "Arşiv"
        case .favorites: return "Favoriler"
        case .pinned: return "İğnelenmiş"
        case .settings: return "Ayarlar"
        case .searchPlaceholder: return "Notlarda, etiketlerde, seslerde ara..."
        case .filterActive: return "Aktif"
        case .filterArchived: return "Arşiv"
        case .filterAll: return "Tümü"
        case .wordCount(let w, let c): return "\(w) kelime · \(c) harf"
        case .noteTitlePlaceholder: return "Not Başlığı..."
        case .emptyNote: return "Boş not..."
        case .deleteConfirm: return "Silinsin mi?"
        case .undo: return "Geri Al"
        case .summarize: return "Notu Özetle"
        case .extractTasks: return "Görevleri Çıkar (Checklist)"
        case .cleanMessyNote: return "Dağınık Notu Düzenle & Yapılandır"
        case .smartTitle: return "Akıllı Başlık Öner"
        case .autoCategorize: return "Otomatik Gruplandır"
        case .speechRecord: return "Sesli Not Al & Yazıya Çevir"
        case .speechRecording: return "Dinleniyor..."
        case .speechStop: return "Kaydı Durdur"
        case .captureScreen: return "Ekran Resmi Çek & Ekle"
        case .ocrExtract: return "Görselden Metin Oku (OCR)"
        case .addReminder: return "Hatırlatıcı Ayarla"
        case .sendToAppleNotes: return "Apple Notlar'a Aktar"
        case .sendToReminders: return "Hatırlatıcılar'a Aktar"
        case .boardTitle: return "Mantar Pano Tahtası"
        case .boardHint: return "Notları tahtada serbestçe konumlandırın"
        case .semanticSearch: return "Semantik Anlamsal Arama"
        case .appearanceTab: return "Görünüm"
        case .generalTab: return "Genel"
        case .aiSpeechTab: return "Yapay Zeka & Ses"
        case .shortcutsTab: return "Kısayollar"
        }
    }
}
