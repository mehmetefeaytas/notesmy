import SwiftUI
import AppKit

public struct MarkdownRendererView: View {
    let markdown: String
    let localColor: NoteColor
    let fontSize: CGFloat
    let fontFamily: FontFamilyOption
    var onToggleChecklist: ((Int) -> Void)? = nil
    var onOpenWikiLink: ((String) -> Void)? = nil
    var onEditRequest: (() -> Void)? = nil

    @State private var copiedCodeBlockId: String? = nil

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
            VStack(alignment: .leading, spacing: 8) {
                if parsedBlocks.isEmpty {
                    Text("Boş not... Yazmaya başlamak için çift tıklayın.")
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
        }
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

    // MARK: - Inline Text (Bold, Italic, Strikethrough, Code, Links)

    @ViewBuilder
    private func renderInlineText(_ text: String) -> some View {
        if text.contains("[[") && text.contains("]]") {
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
                        Text(copiedCodeBlockId == id ? "Kopyalandı" : "Kopyala")
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

        var insideCodeBlock = false
        var currentCodeLanguage = ""
        var currentCodeLines: [String] = []

        for (idx, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Code Block Fencing
            if trimmed.hasPrefix("```") {
                if insideCodeBlock {
                    let codeText = currentCodeLines.joined(separator: "\n")
                    blocks.append(MarkdownBlock(
                        id: "code_\(idx)",
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
                continue
            }

            if insideCodeBlock {
                currentCodeLines.append(line)
                continue
            }

            if trimmed.isEmpty {
                continue
            }

            if trimmed == "---" || trimmed == "***" || trimmed == "___" {
                blocks.append(MarkdownBlock(id: "div_\(idx)", type: .divider))
                continue
            }

            if trimmed.hasPrefix("#### ") {
                blocks.append(MarkdownBlock(id: "h4_\(idx)", type: .header(level: 4, text: String(trimmed.dropFirst(5)))))
                continue
            } else if trimmed.hasPrefix("### ") {
                blocks.append(MarkdownBlock(id: "h3_\(idx)", type: .header(level: 3, text: String(trimmed.dropFirst(4)))))
                continue
            } else if trimmed.hasPrefix("## ") {
                blocks.append(MarkdownBlock(id: "h2_\(idx)", type: .header(level: 2, text: String(trimmed.dropFirst(3)))))
                continue
            } else if trimmed.hasPrefix("# ") {
                blocks.append(MarkdownBlock(id: "h1_\(idx)", type: .header(level: 1, text: String(trimmed.dropFirst(2)))))
                continue
            }

            if trimmed.hasPrefix("- [x] ") || trimmed.hasPrefix("- [X] ") {
                blocks.append(MarkdownBlock(id: "chk_\(idx)", type: .checklist(lineIndex: idx, isChecked: true, text: String(trimmed.dropFirst(6)))))
                continue
            } else if trimmed.hasPrefix("- [ ] ") {
                blocks.append(MarkdownBlock(id: "chk_\(idx)", type: .checklist(lineIndex: idx, isChecked: false, text: String(trimmed.dropFirst(6)))))
                continue
            }

            if trimmed.hasPrefix("> ") {
                blocks.append(MarkdownBlock(id: "quote_\(idx)", type: .blockquote(text: String(trimmed.dropFirst(2)))))
                continue
            }

            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") {
                blocks.append(MarkdownBlock(id: "bullet_\(idx)", type: .bullet(text: String(trimmed.dropFirst(2)))))
                continue
            }

            if let match = trimmed.range(of: #"^\d+\.\s+"#, options: .regularExpression) {
                let numStr = trimmed[match].replacingOccurrences(of: ".", with: "").trimmingCharacters(in: .whitespaces)
                let content = String(trimmed[match.upperBound...])
                blocks.append(MarkdownBlock(id: "num_\(idx)", type: .numbered(number: numStr, text: content)))
                continue
            }

            if trimmed.hasPrefix("[[") && trimmed.hasSuffix("]]") {
                let target = String(trimmed.dropFirst(2).dropLast(2)).trimmingCharacters(in: .whitespaces)
                blocks.append(MarkdownBlock(id: "wiki_\(idx)", type: .wikiLink(targetTitle: target)))
                continue
            }

            blocks.append(MarkdownBlock(id: "p_\(idx)", type: .paragraph(text: line)))
        }

        if insideCodeBlock && !currentCodeLines.isEmpty {
            let codeText = currentCodeLines.joined(separator: "\n")
            blocks.append(MarkdownBlock(id: "code_end", type: .codeBlock(code: codeText, language: currentCodeLanguage)))
        }

        return blocks
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
}

public struct MarkdownBlock: Identifiable {
    public let id: String
    public let type: MarkdownBlockType
}
