import SwiftUI
import AppKit
import Carbon

public struct SettingsView: View {
    @ObservedObject var store = NoteStore.shared
    @ObservedObject var loc = LocalizationService.shared

    @State private var recordingAction: HotKeyAction? = nil
    @State private var localEventMonitor: Any? = nil

    public init() {}

    public var body: some View {
        Form {
            Section(loc.language == .turkish ? "Dil & Genel" : "Language & General") {
                Picker(loc.language == .turkish ? "Uygulama Dili" : "App Language", selection: $loc.language) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
            }

            Section(loc.language == .turkish ? "Ekran Kenar Çubuğu" : "Screen Docking") {
                Picker(loc.language == .turkish ? "Kenar Konumu" : "Dock Location", selection: $store.dockSide) {
                    ForEach(DockSide.allCases) { side in
                        Text(side.title(language: loc.language)).tag(side)
                    }
                }
                .onChange(of: store.dockSide) { _ in
                    store.saveSettings()
                }

                HStack {
                    Text(loc.language == .turkish ? "Üzerine Gelme Gecikmesi:" : "Hover Activation Delay:")
                    Slider(value: $store.activationDelay, in: 0.0...0.8, step: 0.05)
                    Text(String(format: "%.0f ms", store.activationDelay * 1000))
                        .frame(width: 50, alignment: .trailing)
                        .font(.system(.body, design: .monospaced))
                }
                .onChange(of: store.activationDelay) { _ in
                    store.saveSettings()
                }

                Toggle(
                    loc.language == .turkish
                        ? "Tam ekran uygulamalar ve Stage Manager üzerinde göster"
                        : "Show over full-screen apps & Stage Manager",
                    isOn: $store.showOverFullScreen
                )
                .onChange(of: store.showOverFullScreen) { _ in
                    store.saveSettings()
                }
            }

            Section(loc.language == .turkish ? "Klavye Kısayolları (Tıkla ve Yeni Tuşa Bas)" : "Global Hotkeys (Click to Reassign)") {
                VStack(spacing: 8) {
                    ForEach(HotKeyAction.allCases) { action in
                        hotkeyEditableRow(for: action)
                    }

                    HStack {
                        Spacer()
                        Button(loc.language == .turkish ? "Varsayılan Kısayollara Sıfırla" : "Reset Hotkeys to Defaults") {
                            store.resetHotKeysToDefaults()
                            AppDelegate.shared?.setupGlobalHotkeys()
                        }
                        .font(.system(size: 11))
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    }
                    .padding(.top, 4)
                }
            }

            Section(loc.language == .turkish ? "Gizlilik ve Depolama" : "Privacy & Storage") {
                Text(
                    loc.language == .turkish
                        ? "Notlar tamamen yerel olarak Application Support dizininde veya iCloud Drive'da saklanır. Analitik veya üçüncü taraf izleyici bulunmaz."
                        : "Notes are stored 100% locally in your Application Support directory or iCloud Drive container. No analytics, no third-party trackers, zero server requests."
                )
                .font(.system(size: 11))
                .foregroundColor(.secondary)

                HStack {
                    Text("\(loc.language == .turkish ? "Aktif Notlar" : "Active Notes"): \(store.activeNotes.count)")
                    Spacer()
                    Text("\(loc.language == .turkish ? "Arşivlenenler" : "Archived"): \(store.archivedNotes.count)")
                }
                .font(.system(size: 12, weight: .medium))
            }
        }
        .formStyle(.grouped)
        .frame(width: 500, height: 460)
        .onDisappear {
            stopRecordingHotKey()
        }
    }

    private func hotkeyEditableRow(for action: HotKeyAction) -> some View {
        let currentHotKey = store.hotKey(for: action)
        let isRecording = (recordingAction == action)

        return HStack {
            Text(action.title(loc: loc))
                .font(.system(size: 12))
                .foregroundColor(.primary)

            Spacer()

            if isRecording {
                Button(action: {
                    stopRecordingHotKey()
                }) {
                    Text(loc.language == .turkish ? "Tuşlara Basın... (İptal: Esc)" : "Press Keys... (Esc to cancel)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 6) {
                    Text(currentHotKey.displayString)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 0.5)
                        )

                    Button(action: {
                        startRecordingHotKey(for: action)
                    }) {
                        Text(loc.language == .turkish ? "Değiştir" : "Change")
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundColor(Color.accentColor)
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func startRecordingHotKey(for action: HotKeyAction) {
        stopRecordingHotKey()
        recordingAction = action

        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Cancel on Escape
            if event.keyCode == 53 {
                self.stopRecordingHotKey()
                return nil
            }

            // Must have at least Command, Option, or Control
            let flags = event.modifierFlags.intersection([.command, .option, .control, .shift])
            guard !flags.isEmpty else {
                return event
            }

            var carbonMods: UInt32 = 0
            if flags.contains(.command) { carbonMods |= UInt32(cmdKey) }
            if flags.contains(.option) { carbonMods |= UInt32(optionKey) }
            if flags.contains(.control) { carbonMods |= UInt32(controlKey) }
            if flags.contains(.shift) { carbonMods |= UInt32(shiftKey) }

            var displayStr = ""
            if flags.contains(.control) { displayStr += "⌃" }
            if flags.contains(.option) { displayStr += "⌥" }
            if flags.contains(.shift) { displayStr += "⇧" }
            if flags.contains(.command) { displayStr += "⌘" }

            if let characters = event.charactersIgnoringModifiers?.uppercased(), !characters.isEmpty {
                displayStr += characters
            } else {
                displayStr += "Key\(event.keyCode)"
            }

            self.store.setHotKey(
                action: action,
                keyCode: UInt32(event.keyCode),
                modifiers: carbonMods,
                displayString: displayStr
            )

            AppDelegate.shared?.setupGlobalHotkeys()
            self.stopRecordingHotKey()
            return nil
        }
    }

    private func stopRecordingHotKey() {
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
        recordingAction = nil
    }
}
