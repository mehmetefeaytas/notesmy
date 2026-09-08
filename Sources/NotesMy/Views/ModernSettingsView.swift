import SwiftUI
import AppKit
import Carbon

public enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case appearance = "Appearance"
    case aiSpeech = "AI & Voice"
    case hotkeys = "Shortcuts"
    case privacy = "Privacy & Data"
    case updates = "Updates"

    public var id: String { rawValue }

    @MainActor
    public func title(loc: LocalizationService) -> String {
        switch self {
        case .general: return loc.text(.generalTab)
        case .appearance: return loc.text(.appearanceTab)
        case .aiSpeech: return loc.text(.aiSpeechTab)
        case .hotkeys: return loc.text(.shortcutsTab)
        case .privacy: return loc.language == .turkish ? "Gizlilik & Depolama" : "Privacy & Data"
        case .updates: return loc.language == .turkish ? "Güncellemeler" : "Updates"
        }
    }

    public var icon: String {
        switch self {
        case .general: return "gearshape"
        case .appearance: return "textformat.size"
        case .aiSpeech: return "sparkles"
        case .hotkeys: return "command"
        case .privacy: return "lock.shield"
        case .updates: return "arrow.triangle.2.circlepath.circle"
        }
    }
}

public struct ModernSettingsView: View {
    @ObservedObject var store = NoteStore.shared
    @ObservedObject var loc = LocalizationService.shared
    @ObservedObject var updater = UpdateService.shared
    @State private var selectedTab: SettingsTab = .general

    // Interactive Key Recorder State
    @State private var recordingAction: HotKeyAction? = nil
    @State private var keyMonitor: Any? = nil

    // Data Management Alerts
    @State private var showFirstClearAlert = false
    @State private var showSecondClearAlert = false

    public init() {}

    public var body: some View {
        NavigationSplitView {
            List(SettingsTab.allCases, selection: $selectedTab) { tab in
                Label(tab.title(loc: loc), systemImage: tab.icon)
                    .tag(tab)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 170, ideal: 190, max: 230)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch selectedTab {
                    case .general:
                        generalSection
                    case .appearance:
                        appearanceSection
                    case .aiSpeech:
                        aiSpeechSection
                    case .hotkeys:
                        hotkeysSection
                    case .privacy:
                        privacySection
                    case .updates:
                        updatesSection
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .frame(minWidth: 680, minHeight: 480)
        .alert(
            loc.language == .turkish ? "Tüm Notları Silmek İstediğinize Emin Misiniz?" : "Are you sure you want to clear all notes?",
            isPresented: $showFirstClearAlert
        ) {
            Button(loc.language == .turkish ? "İptal" : "Cancel", role: .cancel) {}
            Button(loc.language == .turkish ? "Devam Et" : "Continue", role: .destructive) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    showSecondClearAlert = true
                }
            }
        } message: {
            Text(loc.language == .turkish
                ? "Bu işlem mevcut tüm aktif ve arşivlenmiş notlarınızı ve yerel eklerini silecektir. Onaylamak için bir adım daha gerekiyor."
                : "This action will delete all active and archived notes and attachments. A secondary confirmation is required.")
        }
        .alert(
            loc.language == .turkish ? "⚠️ DİKKAT: Bu İşlem Geri Alınamaz!" : "⚠️ CAUTION: Cannot Be Undone!",
            isPresented: $showSecondClearAlert
        ) {
            Button(loc.language == .turkish ? "Vazgeç" : "Cancel", role: .cancel) {}
            Button(loc.language == .turkish ? "Evet, Tüm Notları Kalıcı Olarak Sil" : "Yes, Permanently Clear All Notes", role: .destructive) {
                store.clearAllNotes()
            }
        } message: {
            Text(loc.language == .turkish
                ? "Tüm notlarınız tamamen silinecektir. Bu işlemi geri alamazsınız. Gerçekten sıfırlamak istiyor musunuz?"
                : "All your notes and media attachments will be permanently deleted. Are you absolutely certain?")
        }
        .onDisappear {
            stopRecording()
        }
    }

    // MARK: - General Tab

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerTitle(
                title: loc.text(.generalTab),
                subtitle: loc.language == .turkish ? "Dil, kenar çubuğu davranışı ve görüntüleme tercihleri" : "Language, dock behavior and display preferences"
            )

            GroupBox(loc.language == .turkish ? "Uygulama Dili" : "App Language") {
                VStack(alignment: .leading, spacing: 12) {
                    Picker(loc.language == .turkish ? "Arayüz Dili:" : "Interface Language:", selection: $loc.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text("\(lang.flag) \(lang.displayName)").tag(lang)
                        }
                    }
                    .pickerStyle(.menu)

                    Text(loc.language == .turkish ? "Tüm arayüz metinleri, yapay zeka özetleri ve ses tanıma seçilen dili kullanır. İlk açılışta sistem diliniz otomatik algılanır." : "All UI text, AI summaries and voice recognition use the selected language. Auto-detected from your system on first launch.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(10)
            }

            GroupBox(loc.language == .turkish ? "Ekran Kenarına Kenetlenme (Dock)" : "Screen Docking") {
                VStack(alignment: .leading, spacing: 14) {
                    Picker(loc.language == .turkish ? "Kenetleme Konumu:" : "Dock Edge Location:", selection: $store.dockSide) {
                        ForEach(DockSide.allCases) { side in
                            Text(side.title(language: loc.language)).tag(side)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: store.dockSide) { _ in store.saveSettings() }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(loc.language == .turkish ? "Fare ile Üzerine Gelince Açılma Gecikmesi:" : "Hover Activation Delay:")
                            Spacer()
                            Text(String(format: "%.0f ms", store.activationDelay * 1000))
                                .font(.system(.body, design: .monospaced))
                        }
                        Slider(value: $store.activationDelay, in: 0.0...0.8, step: 0.05)
                            .onChange(of: store.activationDelay) { _ in store.saveSettings() }
                    }

                    Toggle(loc.language == .turkish ? "Tam ekran uygulamaların ve Stage Manager'ın üzerinde göster" : "Show over full-screen apps & Stage Manager", isOn: $store.showOverFullScreen)
                        .onChange(of: store.showOverFullScreen) { _ in store.saveSettings() }
                }
                .padding(10)
            }

            // Software Version & Update Quick Card
            GroupBox(loc.language == .turkish ? "Yazılım Sürümü & Güncellemeler" : "Software Version & Updates") {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("NotesMy v\(updater.currentVersion)")
                                .font(.system(size: 12, weight: .bold))
                            statusBadge
                        }
                        Text(loc.language == .turkish
                             ? "Otomatik kontrol: \(updater.autoCheckEnabled ? "Açık" : "Kapalı")"
                             : "Auto-check: \(updater.autoCheckEnabled ? "On" : "Off")")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(loc.language == .turkish ? "Güncellemeleri Yönet..." : "Manage Updates...") {
                        selectedTab = .updates
                    }
                    .buttonStyle(.bordered)
                }
                .padding(10)
            }
        }
    }

    // MARK: - Appearance & Typography Tab

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerTitle(
                title: loc.text(.appearanceTab),
                subtitle: loc.language == .turkish ? "Yazı tipi ailesi, metin boyutu ve not kartı boyutları" : "Font family, typography size, and card dimensions"
            )

            GroupBox(loc.language == .turkish ? "Yazı Tipi & Tipografi" : "Typography & Font") {
                VStack(alignment: .leading, spacing: 14) {
                    Picker(loc.language == .turkish ? "Yazı Tipi:" : "Font Family:", selection: $store.selectedFont) {
                        ForEach(FontFamilyOption.allCases) { font in
                            Text(font.rawValue).tag(font)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: store.selectedFont) { _ in store.saveSettings() }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(loc.language == .turkish ? "Metin Boyutu:" : "Font Size:")
                            Spacer()
                            Text("\(Int(store.fontSize)) pt")
                                .font(.system(.body, design: .monospaced))
                        }
                        Slider(value: $store.fontSize, in: 11...22, step: 1)
                            .onChange(of: store.fontSize) { _ in store.saveSettings() }
                    }

                    Picker(loc.language == .turkish ? "Varsayılan Not Boyutu:" : "Default Card Dimensions:", selection: $store.cardSize) {
                        ForEach(CardSizeOption.allCases) { size in
                            Text(cardSizeTitle(size)).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: store.cardSize) { _ in store.saveSettings() }
                }
                .padding(10)
            }

            // Live Typography Preview Card
            GroupBox(loc.language == .turkish ? "Canlı Not Önizlemesi" : "Live Card Preview") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle().fill(Color.orange).frame(width: 10, height: 10)
                        Text(loc.language == .turkish ? "Örnek Yapışkan Not" : "Sample Sticky Note")
                            .font(.system(size: 12, weight: .bold))
                        Spacer()
                        Text(loc.language == .turkish ? "Genel" : "General")
                            .font(.system(size: 9))
                            .padding(.horizontal, 4)
                            .background(Color.black.opacity(0.08))
                            .cornerRadius(3)
                    }

                    Text(loc.language == .turkish ? "Hızlı kahverengi tilki tembel köpeğin üzerinden atlar. Türkçe karakterler: çığıöşü ÇİĞÖŞÜ." : "The quick brown fox jumps over the lazy dog. Multilingual support: çığıöşü.")
                        .font(store.selectedFont.font(size: store.fontSize))
                        .lineLimit(3)

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(loc.language == .turkish ? "Tamamlanan görev maddesi önizlemesi" : "Completed task item preview")
                            .font(store.selectedFont.font(size: store.fontSize - 1))
                    }
                }
                .padding(14)
                .background(NoteColor.amber.primaryColor)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(NoteColor.amber.borderTone, lineWidth: 1))
                .padding(6)
            }
        }
    }

    private func cardSizeTitle(_ size: CardSizeOption) -> String {
        switch size {
        case .compact:  return loc.language == .turkish ? "Kompakt" : "Compact"
        case .standard: return loc.language == .turkish ? "Standart" : "Standard"
        case .large:    return loc.language == .turkish ? "Geniş" : "Large"
        }
    }

    // MARK: - AI & Voice Tab

    private var aiSpeechSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerTitle(
                title: loc.text(.aiSpeechTab),
                subtitle: loc.language == .turkish ? "Cihaz üzerinde Ses Tanıma, Apple Vision OCR ve Doğal Dil İşleme" : "On-device Speech Recognition, Apple Vision OCR, and NLP"
            )

            GroupBox(loc.language == .turkish ? "Apple Intelligence & Yapay Zeka Araçları" : "Apple Intelligence & NLP Tools") {
                VStack(alignment: .leading, spacing: 10) {
                    featureRow(
                        icon: "wand.and.stars",
                        title: loc.language == .turkish ? "Karışık Düşünceleri Düzenle & Yapılandır" : "Format & Structure Messy Braindumps",
                        description: loc.language == .turkish ? "Dağınık beyin fırtınalarını ve hızlı notları otomatik olarak temiz paragraflara, vurgulara ve yapılacaklar listelerine dönüştürür." : "Cleans unorganized thoughts into clean paragraphs, highlights, and action lists automatically."
                    )
                    Divider()
                    featureRow(
                        icon: "sparkles",
                        title: loc.language == .turkish ? "Akıllı Not Özeti" : "Smart Summaries",
                        description: loc.language == .turkish ? "Uzun notların ve web sayfalarının cihaz üzerinde anında net özetini oluşturur." : "Generates concise, informative summaries of long notes instantly on device."
                    )
                    Divider()
                    featureRow(
                        icon: "sparkles.rectangle.stack",
                        title: loc.language == .turkish ? "Anlamsal Vektör Arama" : "Semantic Vector Search",
                        description: loc.language == .turkish ? "Apple NaturalLanguage gömme modellerini kullanarak eşanlamlı ve kavramsal benzerliklere göre not bulur." : "Uses Apple NaturalLanguage embeddings to match notes by conceptual meaning and synonyms."
                    )
                }
                .padding(10)
            }

            GroupBox(loc.language == .turkish ? "Ses ve Görüntü İşleme (%100 Çevrimdışı)" : "Voice & Vision (100% Offline)") {
                VStack(alignment: .leading, spacing: 10) {
                    featureRow(
                        icon: "mic.fill",
                        title: loc.language == .turkish ? "Sesten Metne Dönüştürme (Dikte)" : "Speech-to-Text Transcription",
                        description: loc.language == .turkish ? "Apple SFSpeechRecognizer motoru ile 12 dilde yerel, çevrimdışı ve gizli ses tanıma desteği." : "Powered by Apple SFSpeechRecognizer with native multilingual offline support."
                    )
                    Divider()
                    featureRow(
                        icon: "text.viewfinder",
                        title: loc.language == .turkish ? "Görüntüden Metin Çıkarma (Apple Vision OCR)" : "Vision Optical Character Recognition (OCR)",
                        description: loc.language == .turkish ? "Ekran görüntülerindeki ve fotoğraflardaki yazıları Apple Vision ile doğrudan not metnine dönüştürür." : "Apple Vision Framework extracts text from screenshots, photos, and documents directly into notes."
                    )
                }
                .padding(10)
            }
        }
    }

    // MARK: - Hotkeys Tab (Interactive Recorder)

    private var hotkeysSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerTitle(
                title: loc.text(.shortcutsTab),
                subtitle: loc.language == .turkish ? "Klavyenizden istediğiniz tuşlara basarak kısayolları dilediğiniz gibi özelleştirin" : "Customize keyboard shortcuts by pressing your desired key combination"
            )

            // Instruction Callout
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 14))

                Text(loc.language == .turkish ? "Değiştirmek istediğiniz kısayolun yanındaki 'Değiştir' butonuna tıklayın, ardından klavyenizden istediğiniz tuş kombinasyonuna basın (Örn: ⌥⌘N, ⌃⌥V, ⇧⌘L). İptal etmek için Esc tuşuna basın." : "Click 'Change' next to any shortcut, then press your desired key combination (e.g. ⌥⌘N, ⌃⌥V, ⇧⌘L). Press Esc to cancel.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(Color.accentColor.opacity(0.08))
            .cornerRadius(8)

            GroupBox(loc.language == .turkish ? "Özelleştirilebilir Global Kısayollar" : "Customizable Global Shortcuts") {
                VStack(spacing: 10) {
                    ForEach(HotKeyAction.allCases) { action in
                        customHotKeyRow(action: action)
                        if action != HotKeyAction.allCases.last {
                            Divider()
                        }
                    }
                }
                .padding(10)
            }

            HStack {
                Spacer()
                Button(loc.language == .turkish ? "Varsayılan Kısayollara Sıfırla" : "Reset All to Defaults") {
                    store.resetHotKeysToDefaults()
                    AppDelegate.shared?.setupGlobalHotkeys()
                }
                .buttonStyle(.bordered)
            }

            GroupBox(loc.language == .turkish ? "Pencere İçi Kısayollar" : "In-Window Shortcuts") {
                VStack(spacing: 8) {
                    hotkeyItem(title: loc.language == .turkish ? "Önceki / Sonraki Nota Geç" : "Previous / Next Note", keys: "⌘[ / ⌘]")
                    Divider()
                    hotkeyItem(title: loc.language == .turkish ? "Açık Not Penceresini Kapat" : "Close Active Note Window", keys: "Esc")
                }
                .padding(8)
            }
        }
    }

    private func customHotKeyRow(action: HotKeyAction) -> some View {
        let isRecording = recordingAction == action
        let currentKey = store.hotKey(for: action)

        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(action.title(loc: loc))
                    .font(.system(size: 12, weight: .semibold))
                Text(actionSubtitle(action))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isRecording {
                Button(action: {
                    stopRecording()
                }) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text(loc.language == .turkish ? "Tuşlara Basın... (İptal: Esc)" : "Press Keys... (Esc to cancel)")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.accentColor.opacity(0.18))
                    .foregroundColor(Color.accentColor)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.accentColor, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 8) {
                    Text(currentKey.displayString)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 0.8)
                        )

                    Button(loc.language == .turkish ? "Değiştir" : "Change") {
                        startRecording(action: action)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
        }
    }

    private func actionSubtitle(_ action: HotKeyAction) -> String {
        switch action {
        case .newNote:
            return loc.language == .turkish ? "Ekranda kayan yeni bir yapışkan not açar" : "Spawns a floating note on screen"
        case .quickCapture:
            return loc.language == .turkish ? "Panodaki metni tek tıkla nota dönüştürür" : "Converts clipboard content into note"
        case .allNotes:
            return loc.language == .turkish ? "Arama ve filtreleme penceresini açar" : "Opens management and search window"
        case .stickyBoard:
            return loc.language == .turkish ? "Görsel serbest tuvali açar" : "Opens visual sticky board canvas"
        case .archive:
            return loc.language == .turkish ? "Arşivlenen notları listeler" : "Opens archived notes list"
        case .toggleDeck:
            return loc.language == .turkish ? "Ekran kenarı not kartlarını gizler veya gösterir" : "Toggles screen-edge hover deck"
        }
    }

    // MARK: - Key Recording Logic

    private func startRecording(action: HotKeyAction) {
        stopRecording()
        recordingAction = action

        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            var carbonMods: UInt32 = 0
            var modStr = ""

            if flags.contains(.control) { carbonMods |= UInt32(controlKey); modStr += "⌃" }
            if flags.contains(.option)  { carbonMods |= UInt32(optionKey);  modStr += "⌥" }
            if flags.contains(.shift)   { carbonMods |= UInt32(shiftKey);   modStr += "⇧" }
            if flags.contains(.command) { carbonMods |= UInt32(cmdKey);     modStr += "⌘" }

            // Escape without modifiers cancels recording
            if event.keyCode == 53 && carbonMods == 0 {
                Task { @MainActor in
                    stopRecording()
                }
                return nil
            }

            // Must have at least one modifier key
            guard carbonMods > 0 else {
                return nil
            }

            let keyChar: String
            switch event.keyCode {
            case 36: keyChar = "↩"
            case 48: keyChar = "⇥"
            case 49: keyChar = "Space"
            case 51: keyChar = "⌫"
            case 123: keyChar = "←"
            case 124: keyChar = "→"
            case 125: keyChar = "↓"
            case 126: keyChar = "↑"
            default:
                if let chars = event.charactersIgnoringModifiers, !chars.isEmpty {
                    keyChar = chars.uppercased()
                } else {
                    keyChar = "Key\(event.keyCode)"
                }
            }

            let display = "\(modStr)\(keyChar)"
            let keyCode = UInt32(event.keyCode)

            Task { @MainActor in
                store.setHotKey(action: action, keyCode: keyCode, modifiers: carbonMods, displayString: display)
                AppDelegate.shared?.setupGlobalHotkeys()
                stopRecording()
            }
            return nil
        }
    }

    private func stopRecording() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
        recordingAction = nil
    }

    // MARK: - Privacy & Data Tab

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerTitle(
                title: loc.language == .turkish ? "Gizlilik & Depolama" : "Privacy & Storage",
                subtitle: loc.language == .turkish ? "Sıfır telemetri, %100 cihaz üzerinde çalışan yerel mimari" : "Zero telemetry, 100% on-device native architecture"
            )

            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.language == .turkish ? "%100 Cihaz Üzerinde ve Gizli" : "100% On-Device & Private")
                                .font(.system(size: 13, weight: .bold))
                            Text(loc.language == .turkish ? "Telemetri yok, analiz takipçisi yok, üçüncü taraf sunucu yok. Tüm OCR, ses dikte, NLP ve not verileri yalnızca Mac'inizde saklanır." : "No telemetry, no analytics, no third-party servers. All OCR, speech transcription, NLP models, and note storage operate strictly offline on your Mac.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(loc.language == .turkish ? "Aktif Notlar: \(store.activeNotes.count)" : "Active Notes: \(store.activeNotes.count)")
                                .font(.system(size: 12, weight: .medium))
                            Text(loc.language == .turkish ? "Arşivlenen Notlar: \(store.archivedNotes.count)" : "Archived Notes: \(store.archivedNotes.count)")
                                .font(.system(size: 12, weight: .medium))
                        }
                        Spacer()

                        Button(loc.language == .turkish ? "Notlar Klasörünü Finder'da Göster" : "Reveal Notes Folder in Finder") {
                            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: store.attachmentsDirectory.deletingLastPathComponent().path)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(10)
            }

            // Inactive / Stale Notes Section
            let staleNotes = store.inactiveNotes(olderThanDays: 30)
            GroupBox(loc.language == .turkish ? "Kullanılmayan Eski Notlar (>30 Gün)" : "Inactive / Stale Notes (>30 Days)") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.badge.exclamationmark.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.language == .turkish ? "30 günden uzun süredir güncellenmeyen notlar" : "Notes not updated for over 30 days")
                                .font(.system(size: 12, weight: .semibold))
                            Text(loc.language == .turkish
                                 ? "\(staleNotes.count) adet uzun süredir dokunulmayan not tespit edildi."
                                 : "Detected \(staleNotes.count) notes untouched for more than a month.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }

                    if !staleNotes.isEmpty {
                        HStack(spacing: 12) {
                            Button(loc.language == .turkish ? "Eski Notları Arşivle (\(staleNotes.count))" : "Archive Stale Notes (\(staleNotes.count))") {
                                store.archiveInactiveNotes(olderThanDays: 30)
                            }
                            .buttonStyle(.bordered)

                            Button(role: .destructive) {
                                store.deleteInactiveNotes(olderThanDays: 30)
                            } label: {
                                Text(loc.language == .turkish ? "Eski Notları Kalıcı Sil (\(staleNotes.count))" : "Delete Stale Notes (\(staleNotes.count))")
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(10)
            }

            // Danger Zone: Clear All Notes
            GroupBox(loc.language == .turkish ? "Sıfırlama & Temizlik" : "Reset & Maintenance") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.language == .turkish ? "Tüm Notları Temizle" : "Clear All Notes")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.red)
                            Text(loc.language == .turkish
                                 ? "Tüm aktif ve arşivdeki notlarınızı, yerel çizim ve ses eklerini tamamen sıfırlar. İki aşamalı onay istenir."
                                 : "Completely wipes all active and archived notes and their attachments. Two confirmation steps are required.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(role: .destructive) {
                        showFirstClearAlert = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "trash.fill")
                            Text(loc.language == .turkish ? "Tüm Notları Temizle..." : "Clear All Notes...")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .padding(.top, 4)
                }
                .padding(10)
            }
        }
    }

    // MARK: - Software Updates Tab

    private var updatesSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerTitle(
                title: loc.language == .turkish ? "Yazılım Güncellemeleri" : "Software Updates",
                subtitle: loc.language == .turkish
                    ? "Yeni sürümleri denetleyin, otomatik güncelleme kontrolünü yönetin"
                    : "Check for newer versions and manage automatic update checks"
            )

            // Current Version Card
            GroupBox {
                HStack(spacing: 16) {
                    Image(systemName: "app.badge.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.accentColor)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text("NotesMy")
                                .font(.system(size: 16, weight: .bold))
                            Text("v\(updater.currentVersion)")
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundColor(.accentColor)
                                .cornerRadius(4)
                        }

                        Text("macOS Universal Binary (Apple Silicon & Intel 64-bit)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    statusBadge
                }
                .padding(10)
            }

            // Automatic Update Check Setting
            GroupBox(loc.language == .turkish ? "Otomatik Güncelleme Tercihleri" : "Automatic Update Preferences") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(
                        loc.language == .turkish ? "Otomatik Güncelleme Kontrolü" : "Automatically Check for Updates",
                        isOn: $updater.autoCheckEnabled
                    )
                    .font(.system(size: 13, weight: .medium))

                    Text(loc.language == .turkish
                         ? "Etkinleştirildiğinde NotesMy açılışında GitHub Releases üzerinden yeni sürümleri sessizce kontrol eder ve yeni bir sürüm çıktığında bildirim gönderir."
                         : "When enabled, NotesMy silently queries GitHub Releases on startup and alerts you if a newer version is available.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.language == .turkish ? "Son Kontrol:" : "Last Checked:")
                                .font(.system(size: 11, weight: .medium))
                            if let date = updater.lastCheckDate {
                                Text(date.formatted(date: .abbreviated, time: .standard))
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            } else {
                                Text(loc.language == .turkish ? "Henüz yapılmadı" : "Never")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        Button(action: {
                            Task {
                                await updater.checkForUpdates(isUserInitiated: true)
                            }
                        }) {
                            HStack(spacing: 6) {
                                if updater.state == .checking {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                }
                                Text(loc.language == .turkish ? "Güncellemeleri Şimdi Denetle" : "Check for Updates Now")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(updater.state == .checking)
                    }
                }
                .padding(10)
            }

            // Status / Action Area based on state
            switch updater.state {
            case .idle:
                EmptyView()

            case .checking:
                GroupBox {
                    HStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.regular)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.language == .turkish ? "Güncellemeler Aranıyor..." : "Checking for Updates...")
                                .font(.system(size: 13, weight: .semibold))
                            Text("GitHub Releases API (mehmetefeaytas/notesmy)")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(10)
                }

            case .upToDate(let version):
                GroupBox {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.language == .turkish ? "NotesMy Güncel!" : "NotesMy is Up to Date!")
                                .font(.system(size: 13, weight: .bold))
                            Text(loc.language == .turkish
                                 ? "Şu an en son sürümü (v\(version)) kullanıyorsunuz."
                                 : "You are currently running the latest release (v\(version)).")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(10)
                }

            case .updateAvailable(let release):
                GroupBox {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 22))
                                .foregroundColor(.purple)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(loc.language == .turkish ? "🎉 Yeni Sürüm Mevcut: v\(release.version)" : "🎉 New Version Available: v\(release.version)")
                                    .font(.system(size: 14, weight: .bold))
                                if let published = release.publishedAt {
                                    Text("\(release.displayTitle) • \(published.prefix(10))")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }

                        if let body = release.body, !body.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(loc.language == .turkish ? "Sürüm Notları:" : "Release Notes:")
                                    .font(.system(size: 11, weight: .semibold))
                                ScrollView {
                                    Text(body)
                                        .font(.system(size: 11))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8)
                                        .background(Color(nsColor: .controlBackgroundColor))
                                        .cornerRadius(6)
                                }
                                .frame(maxHeight: 120)
                            }
                        }

                        HStack(spacing: 10) {
                            Button(action: {
                                Task {
                                    await updater.downloadAndInstall(release: release)
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.down.circle.fill")
                                    Text(loc.language == .turkish ? "Şimdi İndir & Kur (DMG)" : "Download & Install Now (DMG)")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)

                            Button(action: {
                                updater.openReleasePage(release: release)
                            }) {
                                Text(loc.language == .turkish ? "GitHub'da Aç" : "View on GitHub")
                            }
                            .buttonStyle(.bordered)

                            Button(action: {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString("brew upgrade --cask notesmy", forType: .string)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.on.doc")
                                    Text("brew upgrade")
                                }
                            }
                            .buttonStyle(.bordered)
                            .help(loc.language == .turkish ? "Homebrew güncelleme komutunu panoya kopyala" : "Copy Homebrew upgrade command")
                        }
                    }
                    .padding(10)
                }

            case .downloading(let progress):
                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(loc.language == .turkish ? "Yeni Sürüm İndiriliyor..." : "Downloading Update...")
                                .font(.system(size: 13, weight: .semibold))
                            Spacer()
                            Text(String(format: "%.0f%%", progress * 100))
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                        }

                        ProgressView(value: progress)
                            .progressViewStyle(.linear)

                        HStack {
                            Text(loc.language == .turkish ? "İndirme tamamlandığında DMG otomatik olarak açılacaktır." : "The DMG will open automatically once download finishes.")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(loc.language == .turkish ? "İptal" : "Cancel") {
                                updater.cancelDownload()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                    .padding(10)
                }

            case .readyToInstall(let dmgURL, let version):
                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(loc.language == .turkish ? "NotesMy v\(version) İndirildi!" : "NotesMy v\(version) Downloaded!")
                                    .font(.system(size: 13, weight: .bold))
                                Text(loc.language == .turkish
                                     ? "DMG kalıbı bağlandı ve Finder'da açıldı. NotesMy.app'i Uygulamalar klasörünüze taşıyarak güncellemeyi tamamlayabilirsiniz."
                                     : "DMG is mounted and revealed in Finder. Drag NotesMy.app to your Applications folder to complete the update.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack {
                            Button(loc.language == .turkish ? "Dosyayı Finder'da Göster" : "Show File in Finder") {
                                NSWorkspace.shared.activateFileViewerSelecting([dmgURL])
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(10)
                }

            case .error(let message):
                GroupBox {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.language == .turkish ? "Güncelleme Kontrolü Başarısız" : "Update Check Failed")
                                .font(.system(size: 12, weight: .semibold))
                            Text(message)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(loc.language == .turkish ? "Tekrar Dene" : "Retry") {
                            Task { await updater.checkForUpdates(isUserInitiated: true) }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(10)
                }
            }
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch updater.state {
        case .upToDate:
            Label(loc.language == .turkish ? "Güncel" : "Up to Date", systemImage: "checkmark.circle.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.green)
        case .updateAvailable:
            Label(loc.language == .turkish ? "Yeni Sürüm Var" : "Update Available", systemImage: "arrow.up.circle.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.orange)
        case .checking:
            Label(loc.language == .turkish ? "Kontrol Ediliyor..." : "Checking...", systemImage: "arrow.triangle.2.circlepath")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.blue)
        case .downloading:
            Label(loc.language == .turkish ? "İndiriliyor..." : "Downloading...", systemImage: "arrow.down.circle")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.blue)
        default:
            EmptyView()
        }
    }

    // MARK: - UI Helpers

    private func headerTitle(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.accentColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func hotkeyItem(title: String, keys: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12))
            Spacer()
            Text(keys)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 0.5)
                )
        }
    }
}
