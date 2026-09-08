import Foundation
import SwiftUI

public enum AppLanguage: String, Codable, CaseIterable, Identifiable, Sendable {
    case english    = "en"
    case turkish    = "tr"
    case german     = "de"
    case french     = "fr"
    case spanish    = "es"
    case portuguese = "pt"
    case italian    = "it"
    case russian    = "ru"
    case japanese   = "ja"
    case korean     = "ko"
    case arabic     = "ar"
    case chinese    = "zh"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .english:    return "English"
        case .turkish:    return "Türkçe"
        case .german:     return "Deutsch"
        case .french:     return "Français"
        case .spanish:    return "Español"
        case .portuguese: return "Português"
        case .italian:    return "Italiano"
        case .russian:    return "Русский"
        case .japanese:   return "日本語"
        case .korean:     return "한국어"
        case .arabic:     return "العربية"
        case .chinese:    return "中文"
        }
    }

    public var flag: String {
        switch self {
        case .english:    return "🇬🇧"
        case .turkish:    return "🇹🇷"
        case .german:     return "🇩🇪"
        case .french:     return "🇫🇷"
        case .spanish:    return "🇪🇸"
        case .portuguese: return "🇧🇷"
        case .italian:    return "🇮🇹"
        case .russian:    return "🇷🇺"
        case .japanese:   return "🇯🇵"
        case .korean:     return "🇰🇷"
        case .arabic:     return "🇸🇦"
        case .chinese:    return "🇨🇳"
        }
    }

    /// BCP-47 locale identifier for SFSpeechRecognizer
    public var speechLocale: String {
        switch self {
        case .english:    return "en-US"
        case .turkish:    return "tr-TR"
        case .german:     return "de-DE"
        case .french:     return "fr-FR"
        case .spanish:    return "es-ES"
        case .portuguese: return "pt-BR"
        case .italian:    return "it-IT"
        case .russian:    return "ru-RU"
        case .japanese:   return "ja-JP"
        case .korean:     return "ko-KR"
        case .arabic:     return "ar-SA"
        case .chinese:    return "zh-CN"
        }
    }

    /// Writing direction (RTL support for Arabic)
    public var isRTL: Bool { self == .arabic }
}

@MainActor
public final class LocalizationService: ObservableObject {
    public static let shared = LocalizationService()

    @Published public var language: AppLanguage = .english {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "NotesMyLanguage")
        }
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: "NotesMyLanguage"),
           let lang = AppLanguage(rawValue: saved) {
            self.language = lang
        } else {
            // Auto-detect from system preferred languages
            let pref = Locale.preferredLanguages.first ?? "en"
            if      pref.hasPrefix("tr") { self.language = .turkish }
            else if pref.hasPrefix("de") { self.language = .german }
            else if pref.hasPrefix("fr") { self.language = .french }
            else if pref.hasPrefix("es") { self.language = .spanish }
            else if pref.hasPrefix("pt") { self.language = .portuguese }
            else if pref.hasPrefix("it") { self.language = .italian }
            else if pref.hasPrefix("ru") { self.language = .russian }
            else if pref.hasPrefix("ja") { self.language = .japanese }
            else if pref.hasPrefix("ko") { self.language = .korean }
            else if pref.hasPrefix("ar") { self.language = .arabic }
            else if pref.hasPrefix("zh") { self.language = .chinese }
            else                         { self.language = .english }
        }
    }

    public func text(_ key: LocalizationKey) -> String {
        switch language {
        case .english:    return key.en
        case .turkish:    return key.tr
        case .german:     return key.de
        case .french:     return key.fr
        case .spanish:    return key.es
        case .portuguese: return key.pt
        case .italian:    return key.it
        case .russian:    return key.ru
        case .japanese:   return key.ja
        case .korean:     return key.ko
        case .arabic:     return key.ar
        case .chinese:    return key.zh
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

    // MARK: - English
    public var en: String {
        switch self {
        case .appName:               return "NotesMy"
        case .newNote:               return "New Note"
        case .quickCapture:          return "Quick Capture"
        case .allNotes:              return "All Notes"
        case .stickyBoard:           return "Sticky Board"
        case .archive:               return "Archive"
        case .favorites:             return "Favorites"
        case .pinned:                return "Pinned"
        case .settings:              return "Settings"
        case .searchPlaceholder:     return "Search notes, tags, transcripts..."
        case .filterActive:          return "Active"
        case .filterArchived:        return "Archived"
        case .filterAll:             return "All"
        case .wordCount(let w, let c): return "\(w) words · \(c) chars"
        case .noteTitlePlaceholder:  return "Note Title..."
        case .emptyNote:             return "Empty note..."
        case .deleteConfirm:         return "Delete?"
        case .undo:                  return "Undo"
        case .summarize:             return "Summarize Note"
        case .extractTasks:          return "Extract Action Items"
        case .cleanMessyNote:        return "Format & Organize Messy Note"
        case .smartTitle:            return "Suggest Smart Title"
        case .autoCategorize:        return "Auto-Categorize Note"
        case .speechRecord:          return "Voice Note & Transcribe"
        case .speechRecording:       return "Listening..."
        case .speechStop:            return "Stop Recording"
        case .captureScreen:         return "Capture Screenshot to Note"
        case .ocrExtract:            return "Extract Text from Images (OCR)"
        case .addReminder:           return "Set Reminder Alert"
        case .sendToAppleNotes:      return "Export to Apple Notes"
        case .sendToReminders:       return "Export to Reminders"
        case .boardTitle:            return "Sticky Board Canvas"
        case .boardHint:             return "Drag notes freely across the board"
        case .semanticSearch:        return "Semantic Search"
        case .appearanceTab:         return "Appearance"
        case .generalTab:            return "General"
        case .aiSpeechTab:           return "AI & Voice"
        case .shortcutsTab:          return "Shortcuts"
        }
    }

    // MARK: - Turkish
    public var tr: String {
        switch self {
        case .appName:               return "NotesMy"
        case .newNote:               return "Yeni Not"
        case .quickCapture:          return "Hızlı Yakala"
        case .allNotes:              return "Tüm Notlar"
        case .stickyBoard:           return "Mantar Pano"
        case .archive:               return "Arşiv"
        case .favorites:             return "Favoriler"
        case .pinned:                return "İğnelenmiş"
        case .settings:              return "Ayarlar"
        case .searchPlaceholder:     return "Notlarda, etiketlerde, seslerde ara..."
        case .filterActive:          return "Aktif"
        case .filterArchived:        return "Arşiv"
        case .filterAll:             return "Tümü"
        case .wordCount(let w, let c): return "\(w) kelime · \(c) harf"
        case .noteTitlePlaceholder:  return "Not Başlığı..."
        case .emptyNote:             return "Boş not..."
        case .deleteConfirm:         return "Silinsin mi?"
        case .undo:                  return "Geri Al"
        case .summarize:             return "Notu Özetle"
        case .extractTasks:          return "Görevleri Çıkar"
        case .cleanMessyNote:        return "Dağınık Notu Düzenle"
        case .smartTitle:            return "Akıllı Başlık Öner"
        case .autoCategorize:        return "Otomatik Gruplandır"
        case .speechRecord:          return "Sesli Not Al & Yazıya Çevir"
        case .speechRecording:       return "Dinleniyor..."
        case .speechStop:            return "Kaydı Durdur"
        case .captureScreen:         return "Ekran Resmi Çek & Ekle"
        case .ocrExtract:            return "Görselden Metin Oku (OCR)"
        case .addReminder:           return "Hatırlatıcı Ayarla"
        case .sendToAppleNotes:      return "Apple Notlar'a Aktar"
        case .sendToReminders:       return "Hatırlatıcılar'a Aktar"
        case .boardTitle:            return "Mantar Pano Tahtası"
        case .boardHint:             return "Notları tahtada serbestçe konumlandırın"
        case .semanticSearch:        return "Semantik Anlamsal Arama"
        case .appearanceTab:         return "Görünüm"
        case .generalTab:            return "Genel"
        case .aiSpeechTab:           return "Yapay Zeka & Ses"
        case .shortcutsTab:          return "Kısayollar"
        }
    }

    // MARK: - German
    public var de: String {
        switch self {
        case .appName:               return "NotesMy"
        case .newNote:               return "Neue Notiz"
        case .quickCapture:          return "Schnellerfassung"
        case .allNotes:              return "Alle Notizen"
        case .stickyBoard:           return "Pinnwand"
        case .archive:               return "Archiv"
        case .favorites:             return "Favoriten"
        case .pinned:                return "Angeheftet"
        case .settings:              return "Einstellungen"
        case .searchPlaceholder:     return "Notizen, Tags, Transkripte durchsuchen..."
        case .filterActive:          return "Aktiv"
        case .filterArchived:        return "Archiviert"
        case .filterAll:             return "Alle"
        case .wordCount(let w, let c): return "\(w) Wörter · \(c) Zeichen"
        case .noteTitlePlaceholder:  return "Notiztitel..."
        case .emptyNote:             return "Leere Notiz..."
        case .deleteConfirm:         return "Löschen?"
        case .undo:                  return "Rückgängig"
        case .summarize:             return "Notiz zusammenfassen"
        case .extractTasks:          return "Aufgaben extrahieren"
        case .cleanMessyNote:        return "Unordentliche Notiz formatieren"
        case .smartTitle:            return "Intelligenten Titel vorschlagen"
        case .autoCategorize:        return "Automatisch kategorisieren"
        case .speechRecord:          return "Sprachnotiz & Transkription"
        case .speechRecording:       return "Aufnahme läuft..."
        case .speechStop:            return "Aufnahme stoppen"
        case .captureScreen:         return "Screenshot zur Notiz"
        case .ocrExtract:            return "Text aus Bild extrahieren (OCR)"
        case .addReminder:           return "Erinnerung setzen"
        case .sendToAppleNotes:      return "In Apple Notizen exportieren"
        case .sendToReminders:       return "In Erinnerungen exportieren"
        case .boardTitle:            return "Pinnwand-Leinwand"
        case .boardHint:             return "Notizen frei auf der Pinnwand platzieren"
        case .semanticSearch:        return "Semantische Suche"
        case .appearanceTab:         return "Darstellung"
        case .generalTab:            return "Allgemein"
        case .aiSpeechTab:           return "KI & Sprache"
        case .shortcutsTab:          return "Tastenkürzel"
        }
    }

    // MARK: - French
    public var fr: String {
        switch self {
        case .appName:               return "NotesMy"
        case .newNote:               return "Nouvelle note"
        case .quickCapture:          return "Capture rapide"
        case .allNotes:              return "Toutes les notes"
        case .stickyBoard:           return "Tableau de notes"
        case .archive:               return "Archives"
        case .favorites:             return "Favoris"
        case .pinned:                return "Épinglées"
        case .settings:              return "Paramètres"
        case .searchPlaceholder:     return "Rechercher notes, tags, transcriptions..."
        case .filterActive:          return "Actives"
        case .filterArchived:        return "Archivées"
        case .filterAll:             return "Toutes"
        case .wordCount(let w, let c): return "\(w) mots · \(c) caractères"
        case .noteTitlePlaceholder:  return "Titre de la note..."
        case .emptyNote:             return "Note vide..."
        case .deleteConfirm:         return "Supprimer ?"
        case .undo:                  return "Annuler"
        case .summarize:             return "Résumer la note"
        case .extractTasks:          return "Extraire les tâches"
        case .cleanMessyNote:        return "Formater & organiser la note"
        case .smartTitle:            return "Suggérer un titre intelligent"
        case .autoCategorize:        return "Catégoriser automatiquement"
        case .speechRecord:          return "Note vocale & transcription"
        case .speechRecording:       return "Écoute en cours..."
        case .speechStop:            return "Arrêter l'enregistrement"
        case .captureScreen:         return "Capture d'écran vers note"
        case .ocrExtract:            return "Extraire texte d'image (OCR)"
        case .addReminder:           return "Définir un rappel"
        case .sendToAppleNotes:      return "Exporter vers Notes Apple"
        case .sendToReminders:       return "Exporter vers Rappels"
        case .boardTitle:            return "Tableau de notes"
        case .boardHint:             return "Déplacez librement les notes sur le tableau"
        case .semanticSearch:        return "Recherche sémantique"
        case .appearanceTab:         return "Apparence"
        case .generalTab:            return "Général"
        case .aiSpeechTab:           return "IA & Voix"
        case .shortcutsTab:          return "Raccourcis"
        }
    }

    // MARK: - Spanish
    public var es: String {
        switch self {
        case .appName:               return "NotesMy"
        case .newNote:               return "Nueva nota"
        case .quickCapture:          return "Captura rápida"
        case .allNotes:              return "Todas las notas"
        case .stickyBoard:           return "Panel de notas"
        case .archive:               return "Archivo"
        case .favorites:             return "Favoritos"
        case .pinned:                return "Fijadas"
        case .settings:              return "Ajustes"
        case .searchPlaceholder:     return "Buscar notas, etiquetas, transcripciones..."
        case .filterActive:          return "Activas"
        case .filterArchived:        return "Archivadas"
        case .filterAll:             return "Todas"
        case .wordCount(let w, let c): return "\(w) palabras · \(c) caracteres"
        case .noteTitlePlaceholder:  return "Título de la nota..."
        case .emptyNote:             return "Nota vacía..."
        case .deleteConfirm:         return "¿Eliminar?"
        case .undo:                  return "Deshacer"
        case .summarize:             return "Resumir nota"
        case .extractTasks:          return "Extraer tareas"
        case .cleanMessyNote:        return "Formatear y organizar nota"
        case .smartTitle:            return "Sugerir título inteligente"
        case .autoCategorize:        return "Categorizar automáticamente"
        case .speechRecord:          return "Nota de voz y transcripción"
        case .speechRecording:       return "Escuchando..."
        case .speechStop:            return "Detener grabación"
        case .captureScreen:         return "Capturar pantalla a nota"
        case .ocrExtract:            return "Extraer texto de imagen (OCR)"
        case .addReminder:           return "Establecer recordatorio"
        case .sendToAppleNotes:      return "Exportar a Notas de Apple"
        case .sendToReminders:       return "Exportar a Recordatorios"
        case .boardTitle:            return "Panel de notas adhesivas"
        case .boardHint:             return "Arrastra notas libremente por el panel"
        case .semanticSearch:        return "Búsqueda semántica"
        case .appearanceTab:         return "Apariencia"
        case .generalTab:            return "General"
        case .aiSpeechTab:           return "IA & Voz"
        case .shortcutsTab:          return "Atajos"
        }
    }

    // MARK: - Portuguese (Brazilian)
    public var pt: String {
        switch self {
        case .appName:               return "NotesMy"
        case .newNote:               return "Nova nota"
        case .quickCapture:          return "Captura rápida"
        case .allNotes:              return "Todas as notas"
        case .stickyBoard:           return "Quadro de notas"
        case .archive:               return "Arquivo"
        case .favorites:             return "Favoritos"
        case .pinned:                return "Fixadas"
        case .settings:              return "Configurações"
        case .searchPlaceholder:     return "Pesquisar notas, tags, transcrições..."
        case .filterActive:          return "Ativas"
        case .filterArchived:        return "Arquivadas"
        case .filterAll:             return "Todas"
        case .wordCount(let w, let c): return "\(w) palavras · \(c) caracteres"
        case .noteTitlePlaceholder:  return "Título da nota..."
        case .emptyNote:             return "Nota vazia..."
        case .deleteConfirm:         return "Excluir?"
        case .undo:                  return "Desfazer"
        case .summarize:             return "Resumir nota"
        case .extractTasks:          return "Extrair tarefas"
        case .cleanMessyNote:        return "Formatar e organizar nota"
        case .smartTitle:            return "Sugerir título inteligente"
        case .autoCategorize:        return "Categorizar automaticamente"
        case .speechRecord:          return "Nota de voz & transcrição"
        case .speechRecording:       return "Ouvindo..."
        case .speechStop:            return "Parar gravação"
        case .captureScreen:         return "Capturar tela para nota"
        case .ocrExtract:            return "Extrair texto de imagem (OCR)"
        case .addReminder:           return "Definir lembrete"
        case .sendToAppleNotes:      return "Exportar para Notas Apple"
        case .sendToReminders:       return "Exportar para Lembretes"
        case .boardTitle:            return "Quadro de notas adesivas"
        case .boardHint:             return "Arraste notas livremente pelo quadro"
        case .semanticSearch:        return "Busca semântica"
        case .appearanceTab:         return "Aparência"
        case .generalTab:            return "Geral"
        case .aiSpeechTab:           return "IA & Voz"
        case .shortcutsTab:          return "Atalhos"
        }
    }

    // MARK: - Italian
    public var it: String {
        switch self {
        case .appName:               return "NotesMy"
        case .newNote:               return "Nuova nota"
        case .quickCapture:          return "Acquisizione rapida"
        case .allNotes:              return "Tutte le note"
        case .stickyBoard:           return "Bacheca note"
        case .archive:               return "Archivio"
        case .favorites:             return "Preferiti"
        case .pinned:                return "Bloccate"
        case .settings:              return "Impostazioni"
        case .searchPlaceholder:     return "Cerca note, tag, trascrizioni..."
        case .filterActive:          return "Attive"
        case .filterArchived:        return "Archiviate"
        case .filterAll:             return "Tutte"
        case .wordCount(let w, let c): return "\(w) parole · \(c) caratteri"
        case .noteTitlePlaceholder:  return "Titolo nota..."
        case .emptyNote:             return "Nota vuota..."
        case .deleteConfirm:         return "Eliminare?"
        case .undo:                  return "Annulla"
        case .summarize:             return "Riassumi nota"
        case .extractTasks:          return "Estrai attività"
        case .cleanMessyNote:        return "Formatta e organizza nota"
        case .smartTitle:            return "Suggerisci titolo intelligente"
        case .autoCategorize:        return "Categorizza automaticamente"
        case .speechRecord:          return "Nota vocale & trascrizione"
        case .speechRecording:       return "In ascolto..."
        case .speechStop:            return "Interrompi registrazione"
        case .captureScreen:         return "Cattura schermata nella nota"
        case .ocrExtract:            return "Estrai testo da immagine (OCR)"
        case .addReminder:           return "Imposta promemoria"
        case .sendToAppleNotes:      return "Esporta in Note Apple"
        case .sendToReminders:       return "Esporta in Promemoria"
        case .boardTitle:            return "Bacheca note adesive"
        case .boardHint:             return "Trascina le note liberamente sulla bacheca"
        case .semanticSearch:        return "Ricerca semantica"
        case .appearanceTab:         return "Aspetto"
        case .generalTab:            return "Generale"
        case .aiSpeechTab:           return "IA & Voce"
        case .shortcutsTab:          return "Scorciatoie"
        }
    }

    // MARK: - Russian
    public var ru: String {
        switch self {
        case .appName:               return "NotesMy"
        case .newNote:               return "Новая заметка"
        case .quickCapture:          return "Быстрый захват"
        case .allNotes:              return "Все заметки"
        case .stickyBoard:           return "Доска заметок"
        case .archive:               return "Архив"
        case .favorites:             return "Избранное"
        case .pinned:                return "Закреплённые"
        case .settings:              return "Настройки"
        case .searchPlaceholder:     return "Поиск по заметкам, тегам, транскриптам..."
        case .filterActive:          return "Активные"
        case .filterArchived:        return "Архивные"
        case .filterAll:             return "Все"
        case .wordCount(let w, let c): return "\(w) слов · \(c) символов"
        case .noteTitlePlaceholder:  return "Заголовок заметки..."
        case .emptyNote:             return "Пустая заметка..."
        case .deleteConfirm:         return "Удалить?"
        case .undo:                  return "Отменить"
        case .summarize:             return "Резюмировать заметку"
        case .extractTasks:          return "Извлечь задачи"
        case .cleanMessyNote:        return "Форматировать и упорядочить заметку"
        case .smartTitle:            return "Предложить умный заголовок"
        case .autoCategorize:        return "Автоматически категоризировать"
        case .speechRecord:          return "Голосовая заметка и транскрипция"
        case .speechRecording:       return "Слушаю..."
        case .speechStop:            return "Остановить запись"
        case .captureScreen:         return "Снимок экрана в заметку"
        case .ocrExtract:            return "Извлечь текст из изображения (OCR)"
        case .addReminder:           return "Установить напоминание"
        case .sendToAppleNotes:      return "Экспорт в Apple Notes"
        case .sendToReminders:       return "Экспорт в Напоминания"
        case .boardTitle:            return "Доска стикеров"
        case .boardHint:             return "Свободно перемещайте заметки по доске"
        case .semanticSearch:        return "Семантический поиск"
        case .appearanceTab:         return "Внешний вид"
        case .generalTab:            return "Основные"
        case .aiSpeechTab:           return "ИИ & Голос"
        case .shortcutsTab:          return "Горячие клавиши"
        }
    }

    // MARK: - Japanese
    public var ja: String {
        switch self {
        case .appName:               return "NotesMy"
        case .newNote:               return "新しいメモ"
        case .quickCapture:          return "クイックキャプチャ"
        case .allNotes:              return "すべてのメモ"
        case .stickyBoard:           return "付箋ボード"
        case .archive:               return "アーカイブ"
        case .favorites:             return "お気に入り"
        case .pinned:                return "固定"
        case .settings:              return "設定"
        case .searchPlaceholder:     return "メモ、タグ、文字起こしを検索..."
        case .filterActive:          return "アクティブ"
        case .filterArchived:        return "アーカイブ済み"
        case .filterAll:             return "すべて"
        case .wordCount(let w, let c): return "\(w) 語 · \(c) 文字"
        case .noteTitlePlaceholder:  return "メモのタイトル..."
        case .emptyNote:             return "空のメモ..."
        case .deleteConfirm:         return "削除しますか？"
        case .undo:                  return "元に戻す"
        case .summarize:             return "メモを要約"
        case .extractTasks:          return "タスクを抽出"
        case .cleanMessyNote:        return "乱雑なメモを整形"
        case .smartTitle:            return "スマートタイトルを提案"
        case .autoCategorize:        return "自動分類"
        case .speechRecord:          return "音声メモと文字起こし"
        case .speechRecording:       return "録音中..."
        case .speechStop:            return "録音停止"
        case .captureScreen:         return "スクリーンショットをメモに追加"
        case .ocrExtract:            return "画像からテキスト抽出 (OCR)"
        case .addReminder:           return "リマインダーを設定"
        case .sendToAppleNotes:      return "Apple メモにエクスポート"
        case .sendToReminders:       return "リマインダーにエクスポート"
        case .boardTitle:            return "付箋ボードキャンバス"
        case .boardHint:             return "ボード上でメモを自由に移動"
        case .semanticSearch:        return "セマンティック検索"
        case .appearanceTab:         return "外観"
        case .generalTab:            return "一般"
        case .aiSpeechTab:           return "AI & 音声"
        case .shortcutsTab:          return "ショートカット"
        }
    }

    // MARK: - Korean
    public var ko: String {
        switch self {
        case .appName:               return "NotesMy"
        case .newNote:               return "새 메모"
        case .quickCapture:          return "빠른 캡처"
        case .allNotes:              return "모든 메모"
        case .stickyBoard:           return "스티커 보드"
        case .archive:               return "보관함"
        case .favorites:             return "즐겨찾기"
        case .pinned:                return "고정됨"
        case .settings:              return "설정"
        case .searchPlaceholder:     return "메모, 태그, 기록 검색..."
        case .filterActive:          return "활성"
        case .filterArchived:        return "보관됨"
        case .filterAll:             return "전체"
        case .wordCount(let w, let c): return "\(w) 단어 · \(c) 자"
        case .noteTitlePlaceholder:  return "메모 제목..."
        case .emptyNote:             return "빈 메모..."
        case .deleteConfirm:         return "삭제하시겠습니까?"
        case .undo:                  return "실행 취소"
        case .summarize:             return "메모 요약"
        case .extractTasks:          return "할 일 추출"
        case .cleanMessyNote:        return "메모 서식 정리"
        case .smartTitle:            return "스마트 제목 제안"
        case .autoCategorize:        return "자동 분류"
        case .speechRecord:          return "음성 메모 및 텍스트 변환"
        case .speechRecording:       return "듣는 중..."
        case .speechStop:            return "녹음 중지"
        case .captureScreen:         return "스크린샷을 메모에 추가"
        case .ocrExtract:            return "이미지에서 텍스트 추출 (OCR)"
        case .addReminder:           return "알림 설정"
        case .sendToAppleNotes:      return "Apple 메모로 내보내기"
        case .sendToReminders:       return "미리 알림으로 내보내기"
        case .boardTitle:            return "스티커 보드 캔버스"
        case .boardHint:             return "보드에서 메모를 자유롭게 이동"
        case .semanticSearch:        return "의미론적 검색"
        case .appearanceTab:         return "모양"
        case .generalTab:            return "일반"
        case .aiSpeechTab:           return "AI & 음성"
        case .shortcutsTab:          return "단축키"
        }
    }

    // MARK: - Arabic (RTL)
    public var ar: String {
        switch self {
        case .appName:               return "NotesMy"
        case .newNote:               return "ملاحظة جديدة"
        case .quickCapture:          return "التقاط سريع"
        case .allNotes:              return "كل الملاحظات"
        case .stickyBoard:           return "لوحة الملاحظات"
        case .archive:               return "الأرشيف"
        case .favorites:             return "المفضلة"
        case .pinned:                return "مثبّتة"
        case .settings:              return "الإعدادات"
        case .searchPlaceholder:     return "ابحث في الملاحظات والعلامات والنصوص..."
        case .filterActive:          return "نشطة"
        case .filterArchived:        return "مؤرشفة"
        case .filterAll:             return "الكل"
        case .wordCount(let w, let c): return "\(w) كلمات · \(c) حرف"
        case .noteTitlePlaceholder:  return "عنوان الملاحظة..."
        case .emptyNote:             return "ملاحظة فارغة..."
        case .deleteConfirm:         return "حذف؟"
        case .undo:                  return "تراجع"
        case .summarize:             return "تلخيص الملاحظة"
        case .extractTasks:          return "استخراج المهام"
        case .cleanMessyNote:        return "تنسيق الملاحظة وتنظيمها"
        case .smartTitle:            return "اقتراح عنوان ذكي"
        case .autoCategorize:        return "التصنيف التلقائي"
        case .speechRecord:          return "ملاحظة صوتية ونسخ"
        case .speechRecording:       return "جارٍ الاستماع..."
        case .speechStop:            return "إيقاف التسجيل"
        case .captureScreen:         return "التقاط لقطة شاشة للملاحظة"
        case .ocrExtract:            return "استخراج النص من الصور (OCR)"
        case .addReminder:           return "تعيين تذكير"
        case .sendToAppleNotes:      return "تصدير إلى ملاحظات Apple"
        case .sendToReminders:       return "تصدير إلى التذكيرات"
        case .boardTitle:            return "لوحة الملاحظات اللاصقة"
        case .boardHint:             return "اسحب الملاحظات بحرية على اللوحة"
        case .semanticSearch:        return "البحث الدلالي"
        case .appearanceTab:         return "المظهر"
        case .generalTab:            return "عام"
        case .aiSpeechTab:           return "الذكاء الاصطناعي والصوت"
        case .shortcutsTab:          return "اختصارات"
        }
    }

    // MARK: - Chinese Simplified
    public var zh: String {
        switch self {
        case .appName:               return "NotesMy"
        case .newNote:               return "新建笔记"
        case .quickCapture:          return "快速记录"
        case .allNotes:              return "所有笔记"
        case .stickyBoard:           return "便签板"
        case .archive:               return "归档"
        case .favorites:             return "收藏"
        case .pinned:                return "置顶"
        case .settings:              return "设置"
        case .searchPlaceholder:     return "搜索笔记、标签、转录内容..."
        case .filterActive:          return "活跃"
        case .filterArchived:        return "已归档"
        case .filterAll:             return "全部"
        case .wordCount(let w, let c): return "\(w) 词 · \(c) 字"
        case .noteTitlePlaceholder:  return "笔记标题..."
        case .emptyNote:             return "空白笔记..."
        case .deleteConfirm:         return "删除？"
        case .undo:                  return "撤销"
        case .summarize:             return "总结笔记"
        case .extractTasks:          return "提取任务"
        case .cleanMessyNote:        return "格式化并整理笔记"
        case .smartTitle:            return "建议智能标题"
        case .autoCategorize:        return "自动分类"
        case .speechRecord:          return "语音笔记与转录"
        case .speechRecording:       return "正在聆听..."
        case .speechStop:            return "停止录音"
        case .captureScreen:         return "截图添加到笔记"
        case .ocrExtract:            return "从图片提取文字 (OCR)"
        case .addReminder:           return "设置提醒"
        case .sendToAppleNotes:      return "导出到 Apple 备忘录"
        case .sendToReminders:       return "导出到提醒事项"
        case .boardTitle:            return "便签板画布"
        case .boardHint:             return "在画布上自由拖动笔记"
        case .semanticSearch:        return "语义搜索"
        case .appearanceTab:         return "外观"
        case .generalTab:            return "通用"
        case .aiSpeechTab:           return "AI 与语音"
        case .shortcutsTab:          return "快捷键"
        }
    }
}
