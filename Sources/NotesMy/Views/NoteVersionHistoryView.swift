import SwiftUI

public struct NoteVersionHistoryView: View {
    @ObservedObject var store = NoteStore.shared
    @ObservedObject var loc = LocalizationService.shared
    public var noteId: UUID
    public var onRestore: () -> Void

    @State private var selectedVersionId: UUID?
    @State private var newSnapshotReason: String = ""

    public init(noteId: UUID, onRestore: @escaping () -> Void) {
        self.noteId = noteId
        self.onRestore = onRestore
    }

    private var currentNote: NoteItem? {
        store.notes.first(where: { $0.id == noteId })
    }

    private var versions: [NoteVersion] {
        currentNote?.versions ?? []
    }

    private var selectedVersion: NoteVersion? {
        versions.first(where: { $0.id == selectedVersionId }) ?? versions.first
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.accentColor)
                Text(loc.language == .turkish ? "Versiyon Geçmişi" : "Version History")
                    .font(.system(size: 13, weight: .bold))

                Spacer()

                Button("Save Snapshot Now") {
                    store.createVersionSnapshot(noteId: noteId, reason: "Manual user snapshot")
                }
                .font(.system(size: 11))
                .buttonStyle(.bordered)
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            if versions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.clock")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(loc.language == .turkish ? "Henüz kaydedilmiş versiyon yok" : "No previous versions saved yet")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(loc.language == .turkish ? "Düzenlemeler yaptıkça veya şablon uyguladıkça otomatik versiyonlar kaydedilir." : "Snapshots are automatically created before applying templates or restoring.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            } else {
                HSplitView {
                    // Left: Versions List
                    List(versions, selection: $selectedVersionId) { ver in
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(ver.displayDate)
                                    .font(.system(size: 11, weight: .semibold))
                                Spacer()
                            }
                            if !ver.summary.isEmpty {
                                Text(ver.summary)
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                            Text(ver.previewSnippet)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 3)
                        .tag(ver.id)
                    }
                    .frame(minWidth: 180, maxWidth: 220)

                    // Right: Version Preview & Restore
                    VStack(alignment: .leading, spacing: 10) {
                        if let ver = selectedVersion {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ver.title.isEmpty ? "Untitled Note" : ver.title)
                                        .font(.system(size: 13, weight: .bold))
                                    Text(ver.displayDate)
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()

                                Button("Restore This Version") {
                                    store.restoreVersion(noteId: noteId, versionId: ver.id)
                                    onRestore()
                                }
                                .font(.system(size: 11, weight: .semibold))
                                .buttonStyle(.borderedProminent)
                            }

                            Divider()

                            ScrollView {
                                Text(ver.body)
                                    .font(.system(size: 12))
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                    .textSelection(.enabled)
                            }
                        } else {
                            Text("Select a version to inspect")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(12)
                    .frame(minWidth: 260)
                }
            }
        }
        .frame(width: 520, height: 360)
    }
}
