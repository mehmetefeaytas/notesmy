import SwiftUI
import AppKit
import Carbon

public enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case appearance = "Appearance"
    case aiSpeech = "AI & Voice"
    case hotkeys = "Shortcuts"
    case privacy = "Privacy & Data"

    public var id: String { rawValue }

    @MainActor
    public func title(loc: LocalizationService) -> String {
        switch self {
        case .general: return loc.text(.generalTab)
        case .appearance: return loc.text(.appearanceTab)
        case .aiSpeech: return loc.text(.aiSpeechTab)
        case .hotkeys: return loc.text(.shortcutsTab)
        case .privacy: return loc.language == .turkish ? "Gizlilik & Depolama" : "Privacy & Data"
        }
    }

    public var icon: String {
        switch self {
        case .general: return "gearshape"
        case .appearance: return "textformat.size"
        case .aiSpeech: return "sparkles"
        case .hotkeys: return "command"
        case .privacy: return "lock.shield"
        }
    }
}

public struct ModernSettingsView: View {
    @ObservedObject var store = NoteStore.shared
    @ObservedObject var loc = LocalizationService.shared
    @State private var selectedTab: SettingsTab = .general

    // Interactive Key Recorder State
    @State private var recordingAction: HotKeyAction? = nil
    @State private var keyMonitor: Any? = nil

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
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .frame(minWidth: 680, minHeight: 480)
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
