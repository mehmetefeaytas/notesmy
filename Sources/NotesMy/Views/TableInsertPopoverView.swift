import SwiftUI

public struct TableInsertPopoverView: View {
    @ObservedObject var loc = LocalizationService.shared
    public var onInsertTable: (String) -> Void
    public var onDismiss: () -> Void

    @State private var hoveredCols: Int = 3
    @State private var hoveredRows: Int = 3
    @State private var selectedTab: Int = 0 // 0: Grid / Özel, 1: Hazır Şablonlar
    @State private var customCols: Int = 3
    @State private var customRows: Int = 3

    public init(
        onInsertTable: @escaping (String) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.onInsertTable = onInsertTable
        self.onDismiss = onDismiss
    }

    private var isTurkish: Bool {
        loc.language == .turkish
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Image(systemName: "tablecells.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.accentColor)
                Text(isTurkish ? "Tablo Ekle" : "Insert Table")
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 2)

            // Segmented Picker
            Picker("", selection: $selectedTab) {
                Text(isTurkish ? "Hızlı Matris" : "Quick Grid").tag(0)
                Text(isTurkish ? "Hazır Şablonlar" : "Templates").tag(1)
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            if selectedTab == 0 {
                gridPickerContent
            } else {
                presetsContent
            }
        }
        .padding(14)
        .frame(width: 290)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Grid Picker Content

    private var gridPickerContent: some View {
        VStack(spacing: 8) {
            // Dimension label
            HStack {
                Text("\(hoveredCols) × \(hoveredRows) \(isTurkish ? "Tablo" : "Table")")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.accentColor)
                Spacer()
                Text(isTurkish ? "Hücre seçin" : "Select cells")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            // 5x5 Interactive Matrix
            VStack(spacing: 4) {
                ForEach(1...5, id: \.self) { r in
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { c in
                            let isHighlighted = (c <= hoveredCols && r <= hoveredRows)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(isHighlighted ? Color.accentColor.opacity(0.85) : Color.primary.opacity(0.08))
                                .frame(width: 24, height: 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(isHighlighted ? Color.accentColor : Color.primary.opacity(0.12), lineWidth: 0.5)
                                )
                                .onHover { isHovered in
                                    if isHovered {
                                        hoveredCols = c
                                        hoveredRows = r
                                    }
                                }
                                .onTapGesture {
                                    let md = TableMarkdownHelper.generateMarkdown(cols: c, rows: r, isTurkish: isTurkish)
                                    onInsertTable(md)
                                }
                        }
                    }
                }
            }
            .padding(6)
            .background(Color.primary.opacity(0.03))
            .cornerRadius(8)

            Divider()
                .padding(.vertical, 2)

            // Steppers for Custom Columns & Rows
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Text(isTurkish ? "Sütun:" : "Cols:")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                    Stepper("\(customCols)", value: $customCols, in: 1...10)
                        .font(.system(size: 10, weight: .semibold))
                }

                HStack(spacing: 4) {
                    Text(isTurkish ? "Satır:" : "Rows:")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                    Stepper("\(customRows)", value: $customRows, in: 1...20)
                        .font(.system(size: 10, weight: .semibold))
                }
            }

            Button(action: {
                let md = TableMarkdownHelper.generateMarkdown(cols: customCols, rows: customRows, isTurkish: isTurkish)
                onInsertTable(md)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 10))
                    Text(isTurkish ? "Özel Boyutla Tablo Oluştur" : "Create Custom Table")
                        .font(.system(size: 11, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Presets Content

    private var presetsContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 6) {
                ForEach(TableMarkdownHelper.builtInPresets) { preset in
                    Button(action: {
                        onInsertTable(preset.markdown)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: preset.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.accentColor)
                                .frame(width: 22, height: 22)
                                .background(Color.accentColor.opacity(0.12))
                                .cornerRadius(5)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(isTurkish ? preset.titleTr : preset.titleEn)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text("\(preset.columns) \(isTurkish ? "Sütun" : "Cols") · \(preset.rows) \(isTurkish ? "Satır" : "Rows")")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "arrow.down.doc")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.primary.opacity(0.04))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxHeight: 220)
    }
}
