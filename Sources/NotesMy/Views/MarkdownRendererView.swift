import SwiftUI
import AppKit

public enum CalloutType: String, CaseIterable, Sendable {
    case note = "note"
    case tip = "tip"
    case warning = "warning"
    case important = "important"
    case caution = "caution"
    case success = "success"
    case info = "info"
    case quote = "quote"

    public var iconName: String {
        switch self {
        case .note: return "pin.fill"
        case .tip: return "lightbulb.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .important: return "bolt.fill"
        case .caution: return "exclamationmark.octagon.fill"
        case .success: return "checkmark.circle.fill"
        case .info: return "info.circle.fill"
        case .quote: return "quote.opening"
        }
    }

    public var accentColor: Color {
        switch self {
        case .note: return .blue
        case .tip: return .purple
        case .warning: return .orange
        case .important: return .red
        case .caution: return .red
        case .success: return .green
        case .info: return .cyan
        case .quote: return .secondary
        }
    }

    public func defaultTitle(isTurkish: Bool) -> String {
        switch self {
        case .note: return isTurkish ? "Not" : "Note"
        case .tip: return isTurkish ? "İpucu" : "Tip"
        case .warning: return isTurkish ? "Uyarı" : "Warning"
        case .important: return isTurkish ? "Önemli" : "Important"
        case .caution: return isTurkish ? "Dikkat" : "Caution"
        case .success: return isTurkish ? "Başarılı" : "Success"
        case .info: return isTurkish ? "Bilgi" : "Info"
        case .quote: return isTurkish ? "Alıntı" : "Quote"
        }
    }
}

public enum MarkdownBlockType {
    case header(level: Int, text: String)
    case paragraph(text: String)
    case bullet(text: String)
    case numbered(number: String, text: String)
    case checklist(lineIndex: Int, isChecked: Bool, text: String)
    case blockquote(text: String)
    case codeBlock(code: String, language: String)
    case divider
    case wikiLink(targetTitle: String)
    case table(data: MarkdownTableData)
    case callout(type: CalloutType, title: String, content: String)
    case toggle(title: String, content: String)
}

public struct MarkdownBlock: Identifiable {
    public let id: String
    public let type: MarkdownBlockType
}

public struct MarkdownRendererView: View {
    let markdown: String
    let localColor: NoteColor
    let fontSize: CGFloat
    let fontFamily: FontFamilyOption
    var onToggleChecklist: ((Int) -> Void)? = nil
    var onOpenWikiLink: ((String) -> Void)? = nil
    var onEditRequest: (() -> Void)? = nil

    @State private var copiedCodeBlockId: String? = nil
    @State private var copiedTableBlockId: String? = nil

    public init(
        markdown: String,
        localColor: NoteColor,
        fontSize: CGFloat = 13,
        fontFamily: FontFamilyOption = .rounded,
        onToggleChecklist: ((Int) -> Void)? = nil,
        onOpenWikiLink: ((String) -> Void)? = nil,
        onEditRequest: (() -> Void)? = nil
    ) {
        self.markdown = markdown
        self.localColor = localColor
        self.fontSize = fontSize
        self.fontFamily = fontFamily
        self.onToggleChecklist = onToggleChecklist
        self.onOpenWikiLink = onOpenWikiLink
        self.onEditRequest = onEditRequest
    }

    private var parsedBlocks: [MarkdownBlock] {
        parseMarkdown(markdown)
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 10) {
                if parsedBlocks.isEmpty {
                    Text(LocalizationService.shared.language == .turkish ? "Boş not... Yazmaya başlamak için çift tıklayın." : "Empty note... Double click to start writing.")
                        .font(fontFamily.font(size: fontSize))
                        .foregroundColor(localColor.secondaryTextColor.opacity(0.6))
                        .padding(.vertical, 12)
                } else {
                    ForEach(parsedBlocks) { block in
                        renderBlock(block)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            onEditRequest?()
        }
    }

    // MARK: - Block Rendering

    @ViewBuilder
    private func renderBlock(_ block: MarkdownBlock) -> some View {
        switch block.type {
        case .header(let level, let text):
            renderHeader(level: level, text: text)

        case .paragraph(let text):
            renderInlineText(text)

        case .bullet(let text):
            HStack(alignment: .top, spacing: 6) {
                Text("•")
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundColor(localColor.dotColor)
                renderInlineText(text)
            }

        case .numbered(let num, let text):
            HStack(alignment: .top, spacing: 6) {
                Text("\(num).")
                    .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                    .foregroundColor(localColor.secondaryTextColor)
                renderInlineText(text)
            }

        case .checklist(let lineIndex, let isChecked, let text):
            HStack(alignment: .center, spacing: 8) {
                Button(action: {
                    onToggleChecklist?(lineIndex)
                }) {
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                        .font(.system(size: fontSize + 1, weight: .medium))
                        .foregroundColor(isChecked ? Color.accentColor : localColor.secondaryTextColor)
                }
                .buttonStyle(.plain)

                if isChecked {
                    Text(LocalizedStringKey(text))
                        .font(fontFamily.font(size: fontSize))
                        .strikethrough(true, color: localColor.secondaryTextColor)
                        .foregroundColor(localColor.secondaryTextColor)
                } else {
                    renderInlineText(text)
                }
            }
            .padding(.vertical, 1)

        case .blockquote(let text):
            HStack(alignment: .top, spacing: 8) {
                Rectangle()
                    .fill(localColor.dotColor.opacity(0.8))
                    .frame(width: 3)
                    .cornerRadius(1.5)

                renderInlineText(text)
                    .italic()
                    .foregroundColor(localColor.secondaryTextColor)
            }
            .padding(.leading, 4)
            .padding(.vertical, 2)

        case .codeBlock(let code, let lang):
            renderCodeBlock(code: code, language: lang, id: block.id)

        case .divider:
            Divider()
                .background(localColor.secondaryTextColor.opacity(0.3))
                .padding(.vertical, 4)

        case .wikiLink(let targetTitle):
            Button(action: {
                onOpenWikiLink?(targetTitle)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.system(size: 9, weight: .bold))
                    Text(targetTitle)
                        .font(.system(size: 11, weight: .semibold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.15))
                .foregroundColor(.purple)
                .cornerRadius(6)
            }
            .buttonStyle(.plain)

        case .table(let data):
            renderTable(data: data, id: block.id)

        case .callout(let type, let title, let content):
            renderCallout(type: type, title: title, content: content)

        case .toggle(let title, let content):
            CollapsibleToggleView(
                title: title,
                content: content,
                localColor: localColor,
                fontSize: fontSize,
                fontFamily: fontFamily
            )
        }
    }

    // MARK: - Table Rendering

    @ViewBuilder
    private func renderTable(data: MarkdownTableData, id: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Action bar above table
            HStack(spacing: 6) {
                HStack(spacing: 3) {
                    Image(systemName: "tablecells")
                        .font(.system(size: 9, weight: .semibold))
                    Text("\(data.columnCount) × \(data.rowCount)")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                }
                .foregroundColor(localColor.secondaryTextColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.primary.opacity(0.05))
                .cornerRadius(4)

                Spacer()

                // Copy CSV Button (for Excel / Numbers)
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(data.toCSV(), forType: .string)
                    copiedTableBlockId = id
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if copiedTableBlockId == id { copiedTableBlockId = nil }
                    }
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: copiedTableBlockId == id ? "checkmark" : "tablecells.badge.ellipsis")
                            .font(.system(size: 8))
                        Text(copiedTableBlockId == id ? (LocalizationService.shared.language == .turkish ? "Kopyalandı" : "Copied") : "CSV")
                            .font(.system(size: 8, weight: .semibold))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .help("Excel / Numbers için CSV kopyala")

                // Copy Markdown Button
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(data.toMarkdown(), forType: .string)
                    copiedTableBlockId = "\(id)_md"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if copiedTableBlockId == "\(id)_md" { copiedTableBlockId = nil }
                    }
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: copiedTableBlockId == "\(id)_md" ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 8))
                        Text(copiedTableBlockId == "\(id)_md" ? (LocalizationService.shared.language == .turkish ? "Kopyalandı" : "Copied") : "MD")
                            .font(.system(size: 8, weight: .semibold))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.06))
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .help("Markdown olarak kopyala")
            }
            .padding(.horizontal, 2)

            // Table Content in Horizontal ScrollView
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    // Header Row
                    HStack(spacing: 0) {
                        ForEach(Array(data.headers.enumerated()), id: \.offset) { colIdx, header in
                            let align = colIdx < data.alignments.count ? data.alignments[colIdx] : .left
                            tableCellView(text: header, isHeader: true, alignment: align)

                            if colIdx < data.headers.count - 1 {
                                Rectangle()
                                    .fill(localColor == .slate ? Color.white.opacity(0.15) : Color.black.opacity(0.12))
                                    .frame(width: 1)
                            }
                        }
                    }
                    .background(localColor == .slate ? Color.white.opacity(0.08) : Color.black.opacity(0.06))

                    // Separator Line
                    Rectangle()
                        .fill(localColor == .slate ? Color.white.opacity(0.2) : Color.black.opacity(0.15))
                        .frame(height: 1)

                    // Data Rows
                    ForEach(Array(data.rows.enumerated()), id: \.offset) { rowIdx, row in
                        let isEven = rowIdx % 2 == 0
                        HStack(spacing: 0) {
                            ForEach(0..<data.headers.count, id: \.self) { colIdx in
                                let cellText = colIdx < row.count ? row[colIdx] : ""
                                let align = colIdx < data.alignments.count ? data.alignments[colIdx] : .left
                                tableCellView(text: cellText, isHeader: false, alignment: align)

                                if colIdx < data.headers.count - 1 {
                                    Rectangle()
                                        .fill(localColor == .slate ? Color.white.opacity(0.1) : Color.black.opacity(0.08))
                                        .frame(width: 1)
                                }
                            }
                        }
                        .background(
                            isEven
                                ? Color.clear
                                : (localColor == .slate ? Color.white.opacity(0.03) : Color.black.opacity(0.025))
                        )

                        if rowIdx < data.rows.count - 1 {
                            Rectangle()
                                .fill(localColor == .slate ? Color.white.opacity(0.1) : Color.black.opacity(0.08))
                                .frame(height: 1)
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(localColor == .slate ? Color.white.opacity(0.18) : Color.black.opacity(0.15), lineWidth: 1)
                )
                .cornerRadius(6)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func tableCellView(text: String, isHeader: Bool, alignment: TableColumnAlignment) -> some View {
        let textAlignment: Alignment = {
            switch alignment {
            case .left: return .leading
            case .center: return .center
            case .right: return .trailing
            }
        }()

        HStack {
            if alignment == .right || alignment == .center {
                Spacer(minLength: 0)
            }

            if isHeader {
                Text(LocalizedStringKey(text))
                    .font(fontFamily.font(size: max(11, fontSize - 1), weight: .bold))
                    .foregroundColor(localColor.textColor)
            } else {
                renderCellInlineText(text)
            }

            if alignment == .left || alignment == .center {
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .frame(minWidth: 80, alignment: textAlignment)
    }

    @ViewBuilder
    private func renderCellInlineText(_ text: String) -> some View {
        if let attr = try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            Text(attr)
                .font(fontFamily.font(size: max(11, fontSize - 1)))
                .foregroundColor(localColor.textColor)
        } else {
            Text(LocalizedStringKey(text))
                .font(fontFamily.font(size: max(11, fontSize - 1)))
                .foregroundColor(localColor.textColor)
        }
    }

    // MARK: - Callout Rendering (Notion / Obsidian style)

    @ViewBuilder
    private func renderCallout(type: CalloutType, title: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: type.iconName)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(type.accentColor)
                .frame(width: 20, height: 20)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                if !title.isEmpty {
                    Text(title)
                        .font(fontFamily.font(size: fontSize, weight: .bold))
                        .foregroundColor(localColor.textColor)
                }

                if !content.isEmpty {
                    renderInlineText(content)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(type.accentColor.opacity(localColor == .slate ? 0.15 : 0.09))
        )
        .overlay(
            HStack {
                Rectangle()
                    .fill(type.accentColor)
                    .frame(width: 3.5)
                    .cornerRadius(2)
                Spacer()
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(type.accentColor.opacity(0.25), lineWidth: 0.8)
        )
        .padding(.vertical, 3)
    }

    // MARK: - Headers

    @ViewBuilder
    private func renderHeader(level: Int, text: String) -> some View {
        let size: CGFloat = {
            switch level {
            case 1: return max(18, fontSize + 6)
            case 2: return max(16, fontSize + 4)
            case 3: return max(14, fontSize + 2)
            default: return fontSize + 1
            }
        }()

        Text(LocalizedStringKey(text))
            .font(.system(size: size, weight: .bold, design: .rounded))
            .foregroundColor(localColor.textColor)
            .padding(.top, level == 1 ? 6 : 4)
            .padding(.bottom, 2)
    }

    // MARK: - Inline Text (Bold, Italic, Strikethrough, Highlight, Code, Links)

    @ViewBuilder
    private func renderInlineText(_ text: String) -> some View {
        if text.contains("==") {
            renderHighlightSegments(text)
        } else if text.contains("[[") && text.contains("]]") {
            renderParagraphWithWikiLinks(text)
        } else if let attr = try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            Text(attr)
                .font(fontFamily.font(size: fontSize))
                .foregroundColor(localColor.textColor)
                .lineSpacing(3)
        } else {
            Text(LocalizedStringKey(text))
                .font(fontFamily.font(size: fontSize))
                .foregroundColor(localColor.textColor)
                .lineSpacing(3)
        }
    }

    @ViewBuilder
    private func renderHighlightSegments(_ text: String) -> some View {
        let parts = splitHighlights(text: text)
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                if part.isHighlight {
                    Text(LocalizedStringKey(part.text))
                        .font(fontFamily.font(size: fontSize, weight: .medium))
                        .foregroundColor(localColor == .slate ? .black : localColor.textColor)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.yellow.opacity(0.85))
                        .cornerRadius(3)
                } else if part.text.contains("[[") && part.text.contains("]]") {
                    renderParagraphWithWikiLinks(part.text)
                } else {
                    if let attr = try? AttributedString(markdown: part.text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                        Text(attr)
                            .font(fontFamily.font(size: fontSize))
                            .foregroundColor(localColor.textColor)
                    } else {
                        Text(LocalizedStringKey(part.text))
                            .font(fontFamily.font(size: fontSize))
                            .foregroundColor(localColor.textColor)
                    }
                }
            }
        }
    }

    private struct HighlightPart {
        let text: String
        let isHighlight: Bool
    }

    private func splitHighlights(text: String) -> [HighlightPart] {
        var parts: [HighlightPart] = []
        var remainder = text

        while let openRange = remainder.range(of: "==") {
            let before = String(remainder[..<openRange.lowerBound])
            if !before.isEmpty {
                parts.append(HighlightPart(text: before, isHighlight: false))
            }
            let afterOpen = remainder[openRange.upperBound...]
            if let closeRange = afterOpen.range(of: "==") {
                let content = String(afterOpen[..<closeRange.lowerBound])
                parts.append(HighlightPart(text: content, isHighlight: true))
                remainder = String(afterOpen[closeRange.upperBound...])
            } else {
                parts.append(HighlightPart(text: String(remainder[openRange.lowerBound...]), isHighlight: false))
                remainder = ""
                break
            }
        }

        if !remainder.isEmpty {
            parts.append(HighlightPart(text: remainder, isHighlight: false))
        }

        return parts
    }

    @ViewBuilder
    private func renderParagraphWithWikiLinks(_ text: String) -> some View {
        let parts = splitWikiLinks(text: text)
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                if part.isWikiLink {
                    Button(action: {
                        onOpenWikiLink?(part.text)
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "link")
                                .font(.system(size: 8, weight: .bold))
                            Text(part.text)
                                .font(.system(size: fontSize - 1, weight: .semibold))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple.opacity(0.18))
                        .foregroundColor(.purple)
                        .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                } else {
                    if let attr = try? AttributedString(markdown: part.text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                        Text(attr)
                            .font(fontFamily.font(size: fontSize))
                            .foregroundColor(localColor.textColor)
                    } else {
                        Text(LocalizedStringKey(part.text))
                            .font(fontFamily.font(size: fontSize))
                            .foregroundColor(localColor.textColor)
                    }
                }
            }
        }
    }

    // MARK: - Code Blocks

    @ViewBuilder
    private func renderCodeBlock(code: String, language: String, id: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if !language.isEmpty {
                    Text(language.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                Spacer()

                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(code, forType: .string)
                    copiedCodeBlockId = id
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if copiedCodeBlockId == id {
                            copiedCodeBlockId = nil
                        }
                    }
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: copiedCodeBlockId == id ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 9))
                        Text(copiedCodeBlockId == id ? (LocalizationService.shared.language == .turkish ? "Kopyalandı" : "Copied") : (LocalizationService.shared.language == .turkish ? "Kopyala" : "Copy"))
                            .font(.system(size: 9, weight: .medium))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.08))
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.top, 6)

            Text(code)
                .font(.system(size: max(11, fontSize - 1), weight: .regular, design: .monospaced))
                .foregroundColor(localColor == .slate ? .white : Color.primary)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(localColor == .slate ? 0.35 : 0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.12), lineWidth: 0.5)
        )
        .padding(.vertical, 4)
    }

    // MARK: - Markdown Parsing Logic

    private func parseMarkdown(_ raw: String) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        let lines = raw.components(separatedBy: .newlines)
        let isTurkish = LocalizationService.shared.language == .turkish

        var insideCodeBlock = false
        var currentCodeLanguage = ""
        var currentCodeLines: [String] = []

        var i = 0
        while i < lines.count {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Code Block Fencing
            if trimmed.hasPrefix("```") {
                if insideCodeBlock {
                    let codeText = currentCodeLines.joined(separator: "\n")
                    blocks.append(MarkdownBlock(
                        id: "code_\(i)",
                        type: .codeBlock(code: codeText, language: currentCodeLanguage)
                    ))
                    insideCodeBlock = false
                    currentCodeLines.removeAll()
                    currentCodeLanguage = ""
                } else {
                    insideCodeBlock = true
                    currentCodeLanguage = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    currentCodeLines.removeAll()
                }
                i += 1
                continue
            }

            if insideCodeBlock {
                currentCodeLines.append(line)
                i += 1
                continue
            }

            if trimmed.isEmpty {
                i += 1
                continue
            }

            // Divider
            if trimmed == "---" || trimmed == "***" || trimmed == "___" {
                blocks.append(MarkdownBlock(id: "div_\(i)", type: .divider))
                i += 1
                continue
            }

            // Markdown Table Check
            if trimmed.contains("|") && i + 1 < lines.count && TableMarkdownHelper.isTableSeparator(line: lines[i + 1]) {
                let headerRow = lines[i]
                let separatorRow = lines[i + 1]

                let headers = TableMarkdownHelper.splitRow(headerRow)
                let alignments = TableMarkdownHelper.parseAlignments(separatorLine: separatorRow)

                var rows: [[String]] = []
                i += 2 // skip header and separator
                while i < lines.count {
                    let nextRow = lines[i].trimmingCharacters(in: .whitespaces)
                    if nextRow.isEmpty || !nextRow.contains("|") {
                        break
                    }
                    let cells = TableMarkdownHelper.splitRow(nextRow)
                    rows.append(cells)
                    i += 1
                }

                let tableData = MarkdownTableData(headers: headers, alignments: alignments, rows: rows)
                blocks.append(MarkdownBlock(id: "table_\(i)", type: .table(data: tableData)))
                continue
            }

            // Collapsible Details Check (<details> ... </details>)
            if trimmed.hasPrefix("<details>") {
                var toggleTitle = isTurkish ? "Detay" : "Details"
                var toggleContentLines: [String] = []
                i += 1

                while i < lines.count {
                    let dLine = lines[i].trimmingCharacters(in: .whitespaces)
                    if dLine.hasPrefix("<summary>") && dLine.contains("</summary>") {
                        let titleCandidate = dLine.replacingOccurrences(of: "<summary>", with: "")
                            .replacingOccurrences(of: "</summary>", with: "")
                            .trimmingCharacters(in: .whitespaces)
                        if !titleCandidate.isEmpty {
                            toggleTitle = titleCandidate
                        }
                    } else if dLine.hasPrefix("</details>") {
                        i += 1
                        break
                    } else {
                        toggleContentLines.append(lines[i])
                    }
                    i += 1
                }

                let bodyText = toggleContentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                blocks.append(MarkdownBlock(id: "toggle_\(i)", type: .toggle(title: toggleTitle, content: bodyText)))
                continue
            }

            // Callout / Blockquote Check (> [!NOTE] or > [!TIP] etc.)
            if trimmed.hasPrefix(">") {
                let quoteText = trimmed.hasPrefix("> ") ? String(trimmed.dropFirst(2)) : String(trimmed.dropFirst(1))

                // Check for Callout pattern: [!NOTE], [!TIP], [!WARNING], etc.
                if let calloutMatch = detectCallout(firstLine: quoteText, isTurkish: isTurkish) {
                    var calloutLines: [String] = []
                    i += 1
                    while i < lines.count {
                        let nextTrimmed = lines[i].trimmingCharacters(in: .whitespaces)
                        if nextTrimmed.hasPrefix(">") {
                            let contentLine = nextTrimmed.hasPrefix("> ") ? String(nextTrimmed.dropFirst(2)) : String(nextTrimmed.dropFirst(1))
                            calloutLines.append(contentLine)
                            i += 1
                        } else {
                            break
                        }
                    }
                    let combinedContent = calloutLines.joined(separator: "\n")
                    blocks.append(MarkdownBlock(id: "callout_\(i)", type: .callout(type: calloutMatch.type, title: calloutMatch.title, content: combinedContent)))
                    continue
                } else {
                    blocks.append(MarkdownBlock(id: "quote_\(i)", type: .blockquote(text: quoteText)))
                    i += 1
                    continue
                }
            }

            // Headers
            if trimmed.hasPrefix("#### ") {
                blocks.append(MarkdownBlock(id: "h4_\(i)", type: .header(level: 4, text: String(trimmed.dropFirst(5)))))
                i += 1
                continue
            } else if trimmed.hasPrefix("### ") {
                blocks.append(MarkdownBlock(id: "h3_\(i)", type: .header(level: 3, text: String(trimmed.dropFirst(4)))))
                i += 1
                continue
            } else if trimmed.hasPrefix("## ") {
                blocks.append(MarkdownBlock(id: "h2_\(i)", type: .header(level: 2, text: String(trimmed.dropFirst(3)))))
                i += 1
                continue
            } else if trimmed.hasPrefix("# ") {
                blocks.append(MarkdownBlock(id: "h1_\(i)", type: .header(level: 1, text: String(trimmed.dropFirst(2)))))
                i += 1
                continue
            }

            // Checklists
            if trimmed.hasPrefix("- [x] ") || trimmed.hasPrefix("- [X] ") {
                blocks.append(MarkdownBlock(id: "chk_\(i)", type: .checklist(lineIndex: i, isChecked: true, text: String(trimmed.dropFirst(6)))))
                i += 1
                continue
            } else if trimmed.hasPrefix("- [ ] ") {
                blocks.append(MarkdownBlock(id: "chk_\(i)", type: .checklist(lineIndex: i, isChecked: false, text: String(trimmed.dropFirst(6)))))
                i += 1
                continue
            }

            // Bullets
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
                blocks.append(MarkdownBlock(id: "bullet_\(i)", type: .bullet(text: String(trimmed.dropFirst(2)))))
                i += 1
                continue
            }

            // Numbered list
            if let match = trimmed.range(of: #"^\d+\.\s+"#, options: .regularExpression) {
                let numStr = trimmed[match].replacingOccurrences(of: ".", with: "").trimmingCharacters(in: .whitespaces)
                let content = String(trimmed[match.upperBound...])
                blocks.append(MarkdownBlock(id: "num_\(i)", type: .numbered(number: numStr, text: content)))
                i += 1
                continue
            }

            // Wiki-link standalone
            if trimmed.hasPrefix("[[") && trimmed.hasSuffix("]]") {
                let target = String(trimmed.dropFirst(2).dropLast(2)).trimmingCharacters(in: .whitespaces)
                blocks.append(MarkdownBlock(id: "wiki_\(i)", type: .wikiLink(targetTitle: target)))
                i += 1
                continue
            }

            // Regular paragraph
            blocks.append(MarkdownBlock(id: "p_\(i)", type: .paragraph(text: line)))
            i += 1
        }

        if insideCodeBlock && !currentCodeLines.isEmpty {
            let codeText = currentCodeLines.joined(separator: "\n")
            blocks.append(MarkdownBlock(id: "code_end", type: .codeBlock(code: codeText, language: currentCodeLanguage)))
        }

        return blocks
    }

    private func detectCallout(firstLine: String, isTurkish: Bool) -> (type: CalloutType, title: String)? {
        let trimmed = firstLine.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("[!") else {
            // Check for emoji-based callout triggers
            if trimmed.hasPrefix("💡") {
                return (.tip, String(trimmed.dropFirst(1)).trimmingCharacters(in: .whitespaces))
            } else if trimmed.hasPrefix("⚠️") {
                return (.warning, String(trimmed.dropFirst(1)).trimmingCharacters(in: .whitespaces))
            } else if trimmed.hasPrefix("📌") {
                return (.note, String(trimmed.dropFirst(1)).trimmingCharacters(in: .whitespaces))
            } else if trimmed.hasPrefix("✅") {
                return (.success, String(trimmed.dropFirst(1)).trimmingCharacters(in: .whitespaces))
            }
            return nil
        }

        guard let closeBracket = trimmed.range(of: "]") else { return nil }
        let typeRaw = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: 2)..<closeBracket.lowerBound]).lowercased()
        let customTitle = String(trimmed[closeBracket.upperBound...]).trimmingCharacters(in: .whitespaces)

        let resolvedType: CalloutType
        switch typeRaw {
        case "note", "not": resolvedType = .note
        case "tip", "ipucu", "hint": resolvedType = .tip
        case "warning", "uyari", "dikkat": resolvedType = .warning
        case "important", "onemli", "önemli": resolvedType = .important
        case "caution", "danger", "tehlike": resolvedType = .caution
        case "success", "basari", "başarı", "check": resolvedType = .success
        case "info", "bilgi": resolvedType = .info
        default: resolvedType = .note
        }

        let title = customTitle.isEmpty ? resolvedType.defaultTitle(isTurkish: isTurkish) : customTitle
        return (resolvedType, title)
    }

    private struct WikiPart {
        let text: String
        let isWikiLink: Bool
    }

    private func splitWikiLinks(text: String) -> [WikiPart] {
        var parts: [WikiPart] = []
        var remainder = text

        while let openRange = remainder.range(of: "[[") {
            let before = String(remainder[..<openRange.lowerBound])
            if !before.isEmpty {
                parts.append(WikiPart(text: before, isWikiLink: false))
            }
            let afterOpen = remainder[openRange.upperBound...]
            if let closeRange = afterOpen.range(of: "]]") {
                let title = String(afterOpen[..<closeRange.lowerBound])
                parts.append(WikiPart(text: title, isWikiLink: true))
                remainder = String(afterOpen[closeRange.upperBound...])
            } else {
                parts.append(WikiPart(text: String(remainder[openRange.lowerBound...]), isWikiLink: false))
                remainder = ""
                break
            }
        }

        if !remainder.isEmpty {
            parts.append(WikiPart(text: remainder, isWikiLink: false))
        }

        return parts
    }
}

// MARK: - Interactive Collapsible Toggle Component (Notion Style)

public struct CollapsibleToggleView: View {
    let title: String
    let content: String
    let localColor: NoteColor
    let fontSize: CGFloat
    let fontFamily: FontFamilyOption

    @State private var isExpanded: Bool = false

    public init(
        title: String,
        content: String,
        localColor: NoteColor,
        fontSize: CGFloat,
        fontFamily: FontFamilyOption
    ) {
        self.title = title
        self.content = content
        self.localColor = localColor
        self.fontSize = fontSize
        self.fontFamily = fontFamily
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button(action: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.accentColor)
                        .frame(width: 14)

                    Text(title)
                        .font(fontFamily.font(size: fontSize, weight: .semibold))
                        .foregroundColor(localColor.textColor)

                    Spacer()
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    if let attr = try? AttributedString(markdown: content, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                        Text(attr)
                            .font(fontFamily.font(size: fontSize))
                            .foregroundColor(localColor.textColor)
                            .lineSpacing(2)
                    } else {
                        Text(content)
                            .font(fontFamily.font(size: fontSize))
                            .foregroundColor(localColor.textColor)
                    }
                }
                .padding(.leading, 20)
                .padding(.vertical, 2)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(6)
    }
}
