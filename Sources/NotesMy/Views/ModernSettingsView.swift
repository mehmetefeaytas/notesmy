import SwiftUI
import AppKit

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
        case .privacy: return "Gizlilik & Depolama"
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

    public init() {}

    public var body: some View {
        NavigationSplitView {
            List(SettingsTab.allCases, selection: $selectedTab) { tab in
                Label(tab.title(loc: loc), systemImage: tab.icon)
                    .tag(tab)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 170, ideal: 180, max: 220)
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
        .frame(minWidth: 640, minHeight: 460)
    }

    // MARK: - General Tab

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerTitle(title: loc.text(.generalTab), subtitle: "Language, dock behavior and display preferences")

            GroupBox("Language / Dil") {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("App Language", selection: $loc.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text("\(lang.flag) \(lang.displayName)").tag(lang)
                        }
                    }
                    .pickerStyle(.menu)

                    Text("All UI text, AI summaries and voice recognition use the selected language. Auto-detected from your system on first launch.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(10)
            }

            GroupBox("Screen Docking") {
                VStack(alignment: .leading, spacing: 14) {
                    Picker("Dock Edge Location", selection: $store.dockSide) {
                        ForEach(DockSide.allCases) { side in
                            Text(side.rawValue).tag(side)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: store.dockSide) { _ in store.saveSettings() }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Hover Activation Delay:")
                            Spacer()
                            Text(String(format: "%.0f ms", store.activationDelay * 1000))
                                .font(.system(.body, design: .monospaced))
                        }
                        Slider(value: $store.activationDelay, in: 0.0...0.8, step: 0.05)
                            .onChange(of: store.activationDelay) { _ in store.saveSettings() }
                    }

                    Toggle("Show over full-screen apps & Stage Manager", isOn: $store.showOverFullScreen)
                        .onChange(of: store.showOverFullScreen) { _ in store.saveSettings() }
                }
                .padding(10)
            }
        }
    }

    // MARK: - Appearance & Typography Tab

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerTitle(title: loc.text(.appearanceTab), subtitle: "Font family, typography size, and card dimensions")

            GroupBox("Typography & Font") {
                VStack(alignment: .leading, spacing: 14) {
                    Picker("Font Family", selection: $store.selectedFont) {
                        ForEach(FontFamilyOption.allCases) { font in
                            Text(font.rawValue).tag(font)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: store.selectedFont) { _ in store.saveSettings() }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Font Size:")
                            Spacer()
                            Text("\(Int(store.fontSize)) pt")
                                .font(.system(.body, design: .monospaced))
                        }
                        Slider(value: $store.fontSize, in: 11...22, step: 1)
                            .onChange(of: store.fontSize) { _ in store.saveSettings() }
                    }

                    Picker("Default Card Dimensions", selection: $store.cardSize) {
                        ForEach(CardSizeOption.allCases) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: store.cardSize) { _ in store.saveSettings() }
                }
                .padding(10)
            }

            // Live Typography Preview Card
            GroupBox("Live Card Preview") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle().fill(Color.orange).frame(width: 10, height: 10)
                        Text("Sample Sticky Note")
                            .font(.system(size: 12, weight: .bold))
                        Spacer()
                        Text("General")
                            .font(.system(size: 9))
                            .padding(.horizontal, 4)
                            .background(Color.black.opacity(0.08))
                            .cornerRadius(3)
                    }

                    Text("The quick brown fox jumps over the lazy dog. Türkçe karakterler: çığıöşü.")
                        .font(store.selectedFont.font(size: store.fontSize))
                        .lineLimit(3)

                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Task item preview")
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

    // MARK: - AI & Voice Tab

    private var aiSpeechSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerTitle(title: loc.text(.aiSpeechTab), subtitle: "On-device Speech Recognition, Apple Vision OCR, and NLP")

            GroupBox("Apple Intelligence & NLP Tools") {
                VStack(alignment: .leading, spacing: 10) {
                    featureRow(
                        icon: "wand.and.stars",
                        title: "Format & Structure Messy Braindumps",
                        description: "Cleans unorganized thoughts into clean paragraphs, highlights, and action lists automatically."
                    )
                    Divider()
                    featureRow(
                        icon: "sparkles",
                        title: "Smart Summaries",
                        description: "Generates concise, informative summaries of long notes instantly on device."
                    )
                    Divider()
                    featureRow(
                        icon: "sparkles.rectangle.stack",
                        title: "Semantic Vector Search",
                        description: "Uses Apple NaturalLanguage embeddings to match notes by conceptual meaning and synonyms."
                    )
                }
                .padding(10)
            }

            GroupBox("Voice & Vision (100% Offline)") {
                VStack(alignment: .leading, spacing: 10) {
                    featureRow(
                        icon: "mic.fill",
                        title: "Speech-to-Text Transcription",
                        description: "Powered by Apple SFSpeechRecognizer with native support for Turkish (tr-TR) and English (en-US)."
                    )
                    Divider()
                    featureRow(
                        icon: "text.viewfinder",
                        title: "Vision Optical Character Recognition (OCR)",
                        description: "Apple Vision Framework extracts text from screenshots, photos, and documents directly into notes."
                    )
                }
                .padding(10)
            }
        }
    }

    // MARK: - Hotkeys Tab

    private var hotkeysSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerTitle(title: loc.text(.shortcutsTab), subtitle: loc.language == .turkish ? "Hızlı verimlilik için global klavye kısayollarını özelleştirin" : "Customize global keyboard shortcuts for instant productivity")

            GroupBox(loc.language == .turkish ? "Kısayol Tuş Kombinasyonu (Değiştirici)" : "Global Shortcut Modifier") {
                VStack(alignment: .leading, spacing: 10) {
                    Picker("", selection: $store.hotkeyModifier) {
                        ForEach(HotKeyModifierOption.allCases) { opt in
                            Text(opt.rawValue).tag(opt)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .onChange(of: store.hotkeyModifier) { _ in
                        store.saveSettings()
                        AppDelegate.shared?.setupGlobalHotkeys()
                    }

                    Text(loc.language == .turkish ? "Kısayol kombinasyonunu değiştirdiğinizde tüm kısayollar anında güncellenir." : "Changing the modifier updates all global productivity shortcuts immediately.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(8)
            }

            GroupBox(loc.language == .turkish ? "Aktif Kısayollar" : "Active Global Shortcuts") {
                VStack(spacing: 8) {
                    hotkeyItem(title: loc.text(.newNote), keys: "\(store.hotkeyModifier.prefix)N")
                    hotkeyItem(title: loc.text(.quickCapture), keys: "\(store.hotkeyModifier.prefix)V")
                    hotkeyItem(title: loc.text(.allNotes), keys: "\(store.hotkeyModifier.prefix)L")
                    hotkeyItem(title: loc.text(.stickyBoard), keys: "\(store.hotkeyModifier.prefix)B")
                    hotkeyItem(title: loc.text(.archive), keys: "\(store.hotkeyModifier.prefix)A")
                    hotkeyItem(title: loc.language == .turkish ? "Kenar Çubuğunu Aç/Kapat" : "Toggle Deck Edge Visibility", keys: "⌃⌥⌘H")
                    hotkeyItem(title: loc.language == .turkish ? "Önceki / Sonraki Not" : "Previous / Next Note", keys: "⌘[ / ⌘]")
                    hotkeyItem(title: loc.language == .turkish ? "Not Penceresini Kapat" : "Close Note Window", keys: "Esc")
                }
                .padding(8)
            }
        }
    }

    // MARK: - Privacy & Data Tab

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerTitle(title: "Privacy & Storage", subtitle: "Zero telemetry, 100% on-device native architecture")

            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("100% On-Device & Private")
                                .font(.system(size: 13, weight: .bold))
                            Text("No telemetry, no analytics, no third-party servers. All OCR, speech transcription, NLP models, and note storage operate strictly offline on your Mac.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Active Notes: \(store.activeNotes.count)")
                                .font(.system(size: 12, weight: .medium))
                            Text("Archived Notes: \(store.archivedNotes.count)")
                                .font(.system(size: 12, weight: .medium))
                        }
                        Spacer()

                        Button("Reveal Notes Folder in Finder") {
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
