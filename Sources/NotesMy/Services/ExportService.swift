import AppKit
import Foundation

@MainActor
public final class ExportService {
    public static let shared = ExportService()

    private init() {}

    // MARK: - Single Note Export (PDF, HTML, RTF, Markdown)

    public func exportNoteToHTML(note: NoteItem) -> String {
        let isDark = (note.color == .slate)
        let bgColor = note.color.cardHex
        let textColor = isDark ? "#F4F4F5" : "#1C1C1E"
        let subtextColor = isDark ? "#A1A1AA" : "#6E6E73"
        let borderColor = isDark ? "#3F3F46" : "#E5E5EA"

        let bodyHTML = convertMarkdownToHTML(note.body)

        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(escapeHTML(note.displayTitle)) - NotesMy</title>
            <style>
                @page {
                    size: A4;
                    margin: 20mm;
                }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Segoe UI", Helvetica, Arial, sans-serif;
                    background-color: #FFFFFF;
                    color: \(textColor);
                    line-height: 1.6;
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 30px;
                }
                .note-card {
                    border: 1px solid \(borderColor);
                    border-radius: 12px;
                    padding: 24px 28px;
                    background-color: \(bgColor)15;
                }
                .header-meta {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    border-bottom: 2px solid \(borderColor);
                    padding-bottom: 12px;
                    margin-bottom: 20px;
                }
                .title {
                    font-size: 26px;
                    font-weight: 700;
                    color: \(textColor);
                    margin: 0 0 6px 0;
                }
                .badge {
                    display: inline-block;
                    font-size: 11px;
                    font-weight: 600;
                    padding: 3px 8px;
                    border-radius: 6px;
                    background-color: #007AFF20;
                    color: #007AFF;
                }
                .date-info {
                    font-size: 12px;
                    color: \(subtextColor);
                }
                h1, h2, h3, h4 {
                    color: \(textColor);
                    font-weight: 600;
                    margin-top: 20px;
                    margin-bottom: 8px;
                }
                h1 { font-size: 22px; border-bottom: 1px solid \(borderColor); padding-bottom: 4px; }
                h2 { font-size: 18px; }
                h3 { font-size: 15px; }
                p { margin: 8px 0; }
                table {
                    width: 100%;
                    border-collapse: collapse;
                    margin: 16px 0;
                    font-size: 13px;
                    border: 1px solid \(borderColor);
                    border-radius: 8px;
                    overflow: hidden;
                }
                th, td {
                    border: 1px solid \(borderColor);
                    padding: 8px 12px;
                    text-align: left;
                }
                th {
                    background-color: #0000000A;
                    font-weight: 700;
                }
                tr:nth-child(even) td {
                    background-color: #00000004;
                }
                .callout {
                    padding: 12px 16px;
                    border-radius: 8px;
                    margin: 14px 0;
                    font-size: 13px;
                }
                .callout-note { background: #007AFF12; border-left: 4px solid #007AFF; }
                .callout-tip { background: #AF52DE12; border-left: 4px solid #AF52DE; }
                .callout-warning { background: #FF950014; border-left: 4px solid #FF9500; }
                .callout-important { background: #FF3B3014; border-left: 4px solid #FF3B30; }
                .callout-success { background: #34C75914; border-left: 4px solid #34C759; }
                .callout-info { background: #5856D612; border-left: 4px solid #5856D6; }
                .callout-title { font-weight: 700; margin-bottom: 4px; }
                mark {
                    background-color: #FEF08A;
                    color: #000000;
                    padding: 1px 4px;
                    border-radius: 4px;
                }
                pre {
                    background-color: #0000000A;
                    border: 1px solid \(borderColor);
                    border-radius: 6px;
                    padding: 10px 14px;
                    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
                    font-size: 12px;
                    overflow-x: auto;
                }
                code {
                    font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
                    background-color: #0000000A;
                    padding: 2px 4px;
                    border-radius: 4px;
                    font-size: 12px;
                }
                .task-list-item {
                    list-style: none;
                    margin-left: -20px;
                    margin-bottom: 4px;
                }
                .task-checked { text-decoration: line-through; color: \(subtextColor); }
                blockquote {
                    border-left: 3px solid \(borderColor);
                    margin: 12px 0;
                    padding-left: 14px;
                    color: \(subtextColor);
                    font-style: italic;
                }
                hr {
                    border: none;
                    border-top: 1px solid \(borderColor);
                    margin: 20px 0;
                }
                .footer {
                    margin-top: 30px;
                    border-top: 1px dashed \(borderColor);
                    padding-top: 10px;
                    font-size: 11px;
                    color: \(subtextColor);
                    text-align: right;
                }
            </style>
        </head>
        <body>
            <div class="note-card">
                <div class="header-meta">
                    <div>
                        <h1 class="title">\(escapeHTML(note.displayTitle))</h1>
                        <span class="badge">\(escapeHTML(note.category))</span>
                    </div>
                    <div class="date-info" style="text-align: right;">
                        <div><strong>\(LocalizationService.shared.language == .turkish ? "Tarih" : "Date"):</strong> \(note.createdAt.formatted(date: .abbreviated, time: .shortened))</div>
                        <div><strong>\(LocalizationService.shared.language == .turkish ? "Güncellendi" : "Updated"):</strong> \(note.updatedAt.formatted(date: .abbreviated, time: .shortened))</div>
                    </div>
                </div>

                <div class="content">
                    \(bodyHTML)
                </div>

                <div class="footer">
                    Exported with NotesMy · \(Date().formatted(date: .abbreviated, time: .shortened))
                </div>
            </div>
        </body>
        </html>
        """
        return html
    }

    public func exportNoteToPDFData(note: NoteItem) -> Data? {
        let html = exportNoteToHTML(note: note)
        guard let htmlData = html.data(using: .utf8) else { return nil }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil) else {
            return nil
        }

        // Standard A4 dimensions
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 36.0
        let contentWidth = pageWidth - (margin * 2)

        let textContainer = NSTextContainer(containerSize: NSSize(width: contentWidth, height: .greatestFiniteMagnitude))
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: attributedString)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        layoutManager.ensureLayout(for: textContainer)

        let usedRect = layoutManager.usedRect(for: textContainer)
        let totalHeight = max(usedRect.height + (margin * 2), pageHeight)

        let printView = NSTextView(frame: NSRect(x: 0, y: 0, width: contentWidth, height: totalHeight))
        printView.textStorage?.setAttributedString(attributedString)

        return printView.dataWithPDF(inside: printView.bounds)
    }

    public func exportNoteToRTFData(note: NoteItem) -> Data? {
        let html = exportNoteToHTML(note: note)
        guard let htmlData = html.data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attr = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil) else {
            return nil
        }
        return try? attr.data(from: NSRange(location: 0, length: attr.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
    }

    public func exportNoteToMarkdownString(note: NoteItem) -> String {
        let content = """
        ---
        title: "\(note.displayTitle)"
        category: "\(note.category)"
        color: "\(note.color.rawValue)"
        date: "\(note.createdAt.ISO8601Format())"
        updated: "\(note.updatedAt.ISO8601Format())"
        tags: [\(note.tags.map { "\"\($0)\"" }.joined(separator: ", "))]
        ---

        # \(note.displayTitle)

        \(note.body)
        """
        return content
    }

    // MARK: - Save Dialog Prompts

    public func promptSaveNoteAsPDF(note: NoteItem, window: NSWindow? = nil) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = sanitizeFileName(note.displayTitle) + ".pdf"
        panel.title = LocalizationService.shared.language == .turkish ? "Notu PDF Olarak Kaydet" : "Save Note as PDF"

        let handler: (NSApplication.ModalResponse) -> Void = { response in
            guard response == .OK, let targetURL = panel.url else { return }
            if let data = self.exportNoteToPDFData(note: note) {
                try? data.write(to: targetURL)
                NSWorkspace.shared.activateFileViewerSelecting([targetURL])
            }
        }

        if let win = window {
            panel.beginSheetModal(for: win, completionHandler: handler)
        } else {
            let response = panel.runModal()
            handler(response)
        }
    }

    public func promptSaveNoteAsHTML(note: NoteItem, window: NSWindow? = nil) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.html]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = sanitizeFileName(note.displayTitle) + ".html"
        panel.title = LocalizationService.shared.language == .turkish ? "Notu HTML Olarak Kaydet" : "Save Note as HTML"

        let handler: (NSApplication.ModalResponse) -> Void = { response in
            guard response == .OK, let targetURL = panel.url else { return }
            let html = self.exportNoteToHTML(note: note)
            try? html.write(to: targetURL, atomically: true, encoding: .utf8)
            NSWorkspace.shared.activateFileViewerSelecting([targetURL])
        }

        if let win = window {
            panel.beginSheetModal(for: win, completionHandler: handler)
        } else {
            let response = panel.runModal()
            handler(response)
        }
    }

    public func promptSaveNoteAsMarkdown(note: NoteItem, window: NSWindow? = nil) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.init(filenameExtension: "md") ?? .plainText]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = sanitizeFileName(note.displayTitle) + ".md"
        panel.title = LocalizationService.shared.language == .turkish ? "Notu Markdown Olarak Kaydet" : "Save Note as Markdown"

        let handler: (NSApplication.ModalResponse) -> Void = { response in
            guard response == .OK, let targetURL = panel.url else { return }
            let md = self.exportNoteToMarkdownString(note: note)
            try? md.write(to: targetURL, atomically: true, encoding: .utf8)
            NSWorkspace.shared.activateFileViewerSelecting([targetURL])
        }

        if let win = window {
            panel.beginSheetModal(for: win, completionHandler: handler)
        } else {
            let response = panel.runModal()
            handler(response)
        }
    }

    public func promptSaveNoteAsRTF(note: NoteItem, window: NSWindow? = nil) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.rtf]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = sanitizeFileName(note.displayTitle) + ".rtf"
        panel.title = LocalizationService.shared.language == .turkish ? "Notu Zengin Metin (RTF) Olarak Kaydet" : "Save Note as RTF"

        let handler: (NSApplication.ModalResponse) -> Void = { response in
            guard response == .OK, let targetURL = panel.url else { return }
            if let data = self.exportNoteToRTFData(note: note) {
                try? data.write(to: targetURL)
                NSWorkspace.shared.activateFileViewerSelecting([targetURL])
            }
        }

        if let win = window {
            panel.beginSheetModal(for: win, completionHandler: handler)
        } else {
            let response = panel.runModal()
            handler(response)
        }
    }

    public func printNote(note: NoteItem, window: NSWindow? = nil) {
        let html = exportNoteToHTML(note: note)
        guard let htmlData = html.data(using: .utf8) else { return }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil) else {
            return
        }

        let printInfo = NSPrintInfo.shared
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .automatic
        printInfo.isHorizontallyCentered = true
        printInfo.isVerticallyCentered = false
        printInfo.topMargin = 36
        printInfo.bottomMargin = 36
        printInfo.leftMargin = 36
        printInfo.rightMargin = 36

        let contentWidth = printInfo.paperSize.width - (printInfo.leftMargin + printInfo.rightMargin)
        let printView = NSTextView(frame: NSRect(x: 0, y: 0, width: contentWidth, height: 100))
        printView.textStorage?.setAttributedString(attributedString)

        let printOperation = NSPrintOperation(view: printView, printInfo: printInfo)
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true

        if let win = window {
            printOperation.runModal(for: win, delegate: nil, didRun: nil, contextInfo: nil)
        } else {
            printOperation.run()
        }
    }

    // MARK: - Multiple Notes PDF Export

    public func exportMultipleNotesToPDFData(notes: [NoteItem], bookTitle: String) -> Data? {
        var combinedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>\(escapeHTML(bookTitle))</title>
            <style>
                @page { size: A4; margin: 20mm; }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", Helvetica, Arial, sans-serif;
                    color: #1C1C1E;
                    padding: 20px;
                }
                .note-entry {
                    page-break-after: always;
                    margin-bottom: 40px;
                }
                .note-entry:last-child { page-break-after: auto; }
                h1.book-title { font-size: 28px; text-align: center; margin-bottom: 30px; }
                .note-header { border-bottom: 2px solid #E5E5EA; padding-bottom: 8px; margin-bottom: 16px; }
                .note-title { font-size: 22px; font-weight: bold; margin: 0; }
                .note-meta { font-size: 11px; color: #8E8E93; margin-top: 4px; }
                table { width: 100%; border-collapse: collapse; margin: 12px 0; font-size: 12px; }
                th, td { border: 1px solid #D1D1D6; padding: 6px 10px; text-align: left; }
                th { background-color: #F2F2F7; font-weight: bold; }
                tr:nth-child(even) td { background-color: #FAFAFC; }
                mark { background-color: #FEF08A; padding: 1px 3px; border-radius: 3px; }
                pre { background: #F2F2F7; padding: 10px; border-radius: 6px; font-family: monospace; font-size: 11px; }
                code { font-family: monospace; background: #E5E5EA; padding: 1px 4px; border-radius: 3px; font-size: 11px; }
                .callout { padding: 10px 14px; border-radius: 6px; margin: 10px 0; background: #F2F2F7; border-left: 4px solid #007AFF; }
            </style>
        </head>
        <body>
            <h1 class="book-title">\(escapeHTML(bookTitle))</h1>
        """

        for note in notes {
            let noteBody = convertMarkdownToHTML(note.body)
            combinedHTML += """
            <div class="note-entry">
                <div class="note-header">
                    <h2 class="note-title">\(escapeHTML(note.displayTitle))</h2>
                    <div class="note-meta">
                        📁 \(escapeHTML(note.category)) · 📅 \(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                    </div>
                </div>
                <div>
                    \(noteBody)
                </div>
            </div>
            """
        }

        combinedHTML += "</body></html>"

        guard let htmlData = combinedHTML.data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attr = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil) else {
            return nil
        }

        let contentWidth: CGFloat = 595.2 - 72.0
        let printView = NSTextView(frame: NSRect(x: 0, y: 0, width: contentWidth, height: 1000))
        printView.textStorage?.setAttributedString(attr)

        return printView.dataWithPDF(inside: printView.bounds)
    }

    public func promptExportAllAsPDF(notes: [NoteItem], window: NSWindow? = nil) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "NotesMy_All_Notes.pdf"
        panel.title = LocalizationService.shared.language == .turkish ? "Tüm Notları PDF Olarak Kaydet" : "Export All Notes as PDF"

        let handler: (NSApplication.ModalResponse) -> Void = { response in
            guard response == .OK, let targetURL = panel.url else { return }
            let bookTitle = LocalizationService.shared.language == .turkish ? "NotesMy Not Arşivi" : "NotesMy Notes Archive"
            if let data = self.exportMultipleNotesToPDFData(notes: notes, bookTitle: bookTitle) {
                try? data.write(to: targetURL)
                NSWorkspace.shared.activateFileViewerSelecting([targetURL])
            }
        }

        if let win = window {
            panel.beginSheetModal(for: win, completionHandler: handler)
        } else {
            let response = panel.runModal()
            handler(response)
        }
    }

    // MARK: - Markdown to HTML Parser

    private func convertMarkdownToHTML(_ markdown: String) -> String {
        let lines = markdown.components(separatedBy: .newlines)
        var result: [String] = []

        var inCodeBlock = false
        var codeBlockLang = ""
        var codeLines: [String] = []

        var i = 0
        while i < lines.count {
            let rawLine = lines[i]
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)

            // Code block
            if trimmed.hasPrefix("```") {
                if inCodeBlock {
                    let codeContent = escapeHTML(codeLines.joined(separator: "\n"))
                    let langAttr = codeBlockLang.isEmpty ? "" : " class=\"language-\(escapeHTML(codeBlockLang))\""
                    result.append("<pre><code\(langAttr)>\(codeContent)</code></pre>")
                    inCodeBlock = false
                    codeLines.removeAll()
                    codeBlockLang = ""
                } else {
                    inCodeBlock = true
                    codeBlockLang = String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    codeLines.removeAll()
                }
                i += 1
                continue
            }

            if inCodeBlock {
                codeLines.append(rawLine)
                i += 1
                continue
            }

            if trimmed.isEmpty {
                i += 1
                continue
            }

            // Divider
            if trimmed == "---" || trimmed == "***" || trimmed == "___" {
                result.append("<hr>")
                i += 1
                continue
            }

            // Table parsing
            if trimmed.contains("|") && i + 1 < lines.count && TableMarkdownHelper.isTableSeparator(line: lines[i + 1]) {
                let headerLine = lines[i]
                let separatorLine = lines[i + 1]

                let headers = TableMarkdownHelper.splitRow(headerLine)
                let alignments = TableMarkdownHelper.parseAlignments(separatorLine: separatorLine)

                var tableHTML = "<table><thead><tr>"
                for (hIdx, header) in headers.enumerated() {
                    let align = hIdx < alignments.count ? alignments[hIdx].rawValue : "left"
                    tableHTML += "<th style=\"text-align: \(align);\">\(formatInlineMarkdown(header))</th>"
                }
                tableHTML += "</tr></thead><tbody>"

                i += 2
                while i < lines.count {
                    let rowLine = lines[i].trimmingCharacters(in: .whitespaces)
                    if rowLine.isEmpty || !rowLine.contains("|") { break }
                    let cells = TableMarkdownHelper.splitRow(rowLine)
                    tableHTML += "<tr>"
                    for colIdx in 0..<headers.count {
                        let text = colIdx < cells.count ? cells[colIdx] : ""
                        let align = colIdx < alignments.count ? alignments[colIdx].rawValue : "left"
                        tableHTML += "<td style=\"text-align: \(align);\">\(formatInlineMarkdown(text))</td>"
                    }
                    tableHTML += "</tr>"
                    i += 1
                }
                tableHTML += "</tbody></table>"
                result.append(tableHTML)
                continue
            }

            // Callouts
            if trimmed.hasPrefix("> [!") && trimmed.contains("]") {
                if let closeBracket = trimmed.range(of: "]") {
                    let typeRaw = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: 4)..<closeBracket.lowerBound]).lowercased()
                    let calloutTitle = String(trimmed[closeBracket.upperBound...]).trimmingCharacters(in: .whitespaces)

                    var calloutLines: [String] = []
                    i += 1
                    while i < lines.count && lines[i].trimmingCharacters(in: .whitespaces).hasPrefix(">") {
                        let cTrim = lines[i].trimmingCharacters(in: .whitespaces)
                        let text = cTrim.hasPrefix("> ") ? String(cTrim.dropFirst(2)) : String(cTrim.dropFirst(1))
                        calloutLines.append(text)
                        i += 1
                    }

                    let calloutClass = "callout callout-\(typeRaw)"
                    let titleHTML = calloutTitle.isEmpty ? typeRaw.capitalized : calloutTitle
                    let bodyHTML = formatInlineMarkdown(calloutLines.joined(separator: "<br>"))

                    result.append("<div class=\"\(calloutClass)\"><div class=\"callout-title\">📌 \(escapeHTML(titleHTML))</div><div>\(bodyHTML)</div></div>")
                    continue
                }
            }

            // Standard blockquote
            if trimmed.hasPrefix("> ") {
                result.append("<blockquote>\(formatInlineMarkdown(String(trimmed.dropFirst(2))))</blockquote>")
                i += 1
                continue
            }

            // Headers
            if trimmed.hasPrefix("#### ") {
                result.append("<h4>\(formatInlineMarkdown(String(trimmed.dropFirst(5))))</h4>")
                i += 1
                continue
            } else if trimmed.hasPrefix("### ") {
                result.append("<h3>\(formatInlineMarkdown(String(trimmed.dropFirst(4))))</h3>")
                i += 1
                continue
            } else if trimmed.hasPrefix("## ") {
                result.append("<h2>\(formatInlineMarkdown(String(trimmed.dropFirst(3))))</h2>")
                i += 1
                continue
            } else if trimmed.hasPrefix("# ") {
                result.append("<h1>\(formatInlineMarkdown(String(trimmed.dropFirst(2))))</h1>")
                i += 1
                continue
            }

            // Checklists
            if trimmed.hasPrefix("- [x] ") || trimmed.hasPrefix("- [X] ") {
                result.append("<div class=\"task-list-item task-checked\">☑️ \(formatInlineMarkdown(String(trimmed.dropFirst(6))))</div>")
                i += 1
                continue
            } else if trimmed.hasPrefix("- [ ] ") {
                result.append("<div class=\"task-list-item\">⬜ \(formatInlineMarkdown(String(trimmed.dropFirst(6))))</div>")
                i += 1
                continue
            }

            // Bullets
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                result.append("<ul><li>\(formatInlineMarkdown(String(trimmed.dropFirst(2))))</li></ul>")
                i += 1
                continue
            }

            // Numbered list
            if let match = trimmed.range(of: #"^\d+\.\s+"#, options: .regularExpression) {
                let numStr = trimmed[match].replacingOccurrences(of: ".", with: "").trimmingCharacters(in: .whitespaces)
                let content = String(trimmed[match.upperBound...])
                result.append("<ol start=\"\(numStr)\"><li>\(formatInlineMarkdown(content))</li></ol>")
                i += 1
                continue
            }

            // Details / Collapsible
            if trimmed.hasPrefix("<details>") {
                result.append(trimmed)
                i += 1
                continue
            }

            // Paragraph
            result.append("<p>\(formatInlineMarkdown(trimmed))</p>")
            i += 1
        }

        if inCodeBlock && !codeLines.isEmpty {
            result.append("<pre><code>\(escapeHTML(codeLines.joined(separator: "\n")))</code></pre>")
        }

        return result.joined(separator: "\n")
    }

    private func formatInlineMarkdown(_ text: String) -> String {
        var str = escapeHTML(text)

        // Highlights ==text== -> <mark>text</mark>
        let highlightRegex = try? NSRegularExpression(pattern: "==(.*?)==([\\s.,;!?]|$)", options: [])
        if let hRegex = highlightRegex {
            str = hRegex.stringByReplacingMatches(in: str, options: [], range: NSRange(location: 0, length: (str as NSString).length), withTemplate: "<mark>$1</mark>$2")
        }

        // Bold **text**
        let boldRegex = try? NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*", options: [])
        if let bRegex = boldRegex {
            str = bRegex.stringByReplacingMatches(in: str, options: [], range: NSRange(location: 0, length: (str as NSString).length), withTemplate: "<strong>$1</strong>")
        }

        // Italic *text*
        let italicRegex = try? NSRegularExpression(pattern: "\\*(.*?)\\*", options: [])
        if let iRegex = italicRegex {
            str = iRegex.stringByReplacingMatches(in: str, options: [], range: NSRange(location: 0, length: (str as NSString).length), withTemplate: "<em>$1</em>")
        }

        // Strikethrough ~~text~~
        let strikeRegex = try? NSRegularExpression(pattern: "~~(.*?)~~", options: [])
        if let sRegex = strikeRegex {
            str = sRegex.stringByReplacingMatches(in: str, options: [], range: NSRange(location: 0, length: (str as NSString).length), withTemplate: "<del>$1</del>")
        }

        // Inline code `text`
        let codeRegex = try? NSRegularExpression(pattern: "`([^`]+)`", options: [])
        if let cRegex = codeRegex {
            str = cRegex.stringByReplacingMatches(in: str, options: [], range: NSRange(location: 0, length: (str as NSString).length), withTemplate: "<code>$1</code>")
        }

        // Links [title](url)
        let linkRegex = try? NSRegularExpression(pattern: "\\[([^\\]]+)\\]\\(([^\\)]+)\\)", options: [])
        if let lRegex = linkRegex {
            str = lRegex.stringByReplacingMatches(in: str, options: [], range: NSRange(location: 0, length: (str as NSString).length), withTemplate: "<a href=\"$2\">$1</a>")
        }

        return str
    }

    private func escapeHTML(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private func sanitizeFileName(_ text: String) -> String {
        let invalid = CharacterSet(charactersIn: "\\/:*?\"<>|")
        let cleaned = text.components(separatedBy: invalid).joined(separator: "_")
        let trimmed = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Note" : String(trimmed.prefix(60))
    }
}
