import SwiftUI

public struct SettingsView: View {
    @ObservedObject var store = NoteStore.shared

    public init() {}

    public var body: some View {
        Form {
            Section("Screen Docking") {
                Picker("Dock Location", selection: $store.dockSide) {
                    ForEach(DockSide.allCases) { side in
                        Text(side.rawValue).tag(side)
                    }
                }
                .onChange(of: store.dockSide) { _ in
                    store.saveSettings()
                }

                HStack {
                    Text("Hover Activation Delay:")
                    Slider(value: $store.activationDelay, in: 0.0...0.8, step: 0.05) {
                        Text("Delay")
                    }
                    Text(String(format: "%.0f ms", store.activationDelay * 1000))
                        .frame(width: 50, alignment: .trailing)
                        .font(.system(.body, design: .monospaced))
                }
                .onChange(of: store.activationDelay) { _ in
                    store.saveSettings()
                }

                Toggle("Show over full-screen apps & Stage Manager", isOn: $store.showOverFullScreen)
                    .onChange(of: store.showOverFullScreen) { _ in
                        store.saveSettings()
                    }
            }

            Section("Global Hotkeys") {
                VStack(alignment: .leading, spacing: 6) {
                    hotkeyRow(title: "New Sticky Note", keys: "⌥⌘N")
                    hotkeyRow(title: "Quick Capture from Clipboard", keys: "⌥⌘V")
                    hotkeyRow(title: "All Notes & Search", keys: "⌥⌘L")
                    hotkeyRow(title: "Open Archive", keys: "⌥⌘A")
                    hotkeyRow(title: "Toggle Deck Visibility", keys: "⌃⌥⌘H")
                    hotkeyRow(title: "Previous / Next Note", keys: "⌘[ / ⌘]")
                    hotkeyRow(title: "Close Note Window", keys: "Esc")
                }
                .font(.system(size: 12))
            }

            Section("Privacy & Storage") {
                Text("Notes are stored 100% locally in your Application Support directory or iCloud Drive container. No analytics, no third-party trackers, zero server requests.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                HStack {
                    Text("Active Notes: \(store.activeNotes.count)")
                    Spacer()
                    Text("Archived: \(store.archivedNotes.count)")
                }
                .font(.system(size: 12, weight: .medium))
            }
        }
        .formStyle(.grouped)
        .frame(width: 460, height: 380)
    }

    private func hotkeyRow(title: String, keys: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(keys)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 0.5)
                )
        }
    }
}
