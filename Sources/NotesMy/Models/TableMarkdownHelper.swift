import Foundation

public enum TableColumnAlignment: String, Codable, Sendable, Equatable {
    case left
    case center
    case right
}

public struct MarkdownTableData: Equatable, Sendable {
    public var headers: [String]
    public var alignments: [TableColumnAlignment]
    public var rows: [[String]]

    public init(headers: [String], alignments: [TableColumnAlignment] = [], rows: [[String]] = []) {
        self.headers = headers
        if alignments.isEmpty {
            self.alignments = Array(repeating: .left, count: headers.count)
        } else {
            self.alignments = alignments
        }
        self.rows = rows
    }

    public var columnCount: Int {
        headers.count
    }

    public var rowCount: Int {
        rows.count
    }

    public func toMarkdown() -> String {
        guard !headers.isEmpty else { return "" }
        var result = ""

        // Header line
        result += "| " + headers.joined(separator: " | ") + " |\n"

        // Separator line
        let separators = (0..<headers.count).map { idx -> String in
            let align = idx < alignments.count ? alignments[idx] : .left
            switch align {
            case .left: return ":---"
            case .center: return ":---:"
            case .right: return "---:"
            }
        }
        result += "| " + separators.joined(separator: " | ") + " |\n"

        // Rows
        for row in rows {
            var padded = row
            while padded.count < headers.count {
                padded.append("")
            }
            if padded.count > headers.count {
                padded = Array(padded.prefix(headers.count))
            }
            result += "| " + padded.joined(separator: " | ") + " |\n"
        }

        return result
    }

    public func toCSV() -> String {
        var lines: [String] = []
        let escapeCSV = { (cell: String) -> String in
            if cell.contains(",") || cell.contains("\"") || cell.contains("\n") {
                let escaped = cell.replacingOccurrences(of: "\"", with: "\"\"")
                return "\"\(escaped)\""
            }
            return cell
        }

        lines.append(headers.map(escapeCSV).joined(separator: ","))
        for row in rows {
            var padded = row
            while padded.count < headers.count { padded.append("") }
            lines.append(padded.prefix(headers.count).map(escapeCSV).joined(separator: ","))
        }
        return lines.joined(separator: "\n")
    }

    public func toTSV() -> String {
        var lines: [String] = []
        lines.append(headers.joined(separator: "\t"))
        for row in rows {
            var padded = row
            while padded.count < headers.count { padded.append("") }
            lines.append(padded.prefix(headers.count).joined(separator: "\t"))
        }
        return lines.joined(separator: "\n")
    }
}

public struct TablePreset: Identifiable, Sendable {
    public var id: String
    public var titleTr: String
    public var titleEn: String
    public var icon: String
    public var columns: Int
    public var rows: Int
    public var markdown: String

    public init(id: String, titleTr: String, titleEn: String, icon: String, columns: Int, rows: Int, markdown: String) {
        self.id = id
        self.titleTr = titleTr
        self.titleEn = titleEn
        self.icon = icon
        self.columns = columns
        self.rows = rows
        self.markdown = markdown
    }
}

public enum TableMarkdownHelper {
    public static func generateMarkdown(cols: Int, rows: Int, isTurkish: Bool = false) -> String {
        let safeCols = max(1, min(cols, 10))
        let safeRows = max(1, min(rows, 25))

        let headers = (1...safeCols).map { isTurkish ? "Başlık \($0)" : "Header \($0)" }
        let alignments = Array(repeating: TableColumnAlignment.left, count: safeCols)
        let rowData = (1...safeRows).map { r in
            (1...safeCols).map { c in isTurkish ? "Veri \(r).\(c)" : "Item \(r).\(c)" }
        }

        let table = MarkdownTableData(headers: headers, alignments: alignments, rows: rowData)
        return table.toMarkdown()
    }

    public static func isTableSeparator(line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.contains("|") || trimmed.contains("-") else { return false }
        let cells = splitRow(line)
        guard !cells.isEmpty else { return false }
        for cell in cells {
            let c = cell.trimmingCharacters(in: .whitespaces)
            guard !c.isEmpty else { continue }
            let stripped = c.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ":", with: "")
            if !stripped.isEmpty || !c.contains("-") {
                return false
            }
        }
        return true
    }

    public static func splitRow(_ line: String) -> [String] {
        var raw = line.trimmingCharacters(in: .whitespaces)
        if raw.hasPrefix("|") { raw.removeFirst() }
        if raw.hasSuffix("|") { raw.removeLast() }
        return raw.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    public static func parseAlignments(separatorLine: String) -> [TableColumnAlignment] {
        let cells = splitRow(separatorLine)
        return cells.map { cell in
            let trimmed = cell.trimmingCharacters(in: .whitespaces)
            let hasStartColon = trimmed.hasPrefix(":")
            let hasEndColon = trimmed.hasSuffix(":")
            if hasStartColon && hasEndColon {
                return .center
            } else if hasEndColon {
                return .right
            } else {
                return .left
            }
        }
    }

    public static let builtInPresets: [TablePreset] = [
        TablePreset(
            id: "standard",
            titleTr: "Standart Tablo",
            titleEn: "Standard Table",
            icon: "tablecells",
            columns: 3,
            rows: 3,
            markdown: """
            | Başlık 1 | Başlık 2 | Başlık 3 |
            | :--- | :--- | :--- |
            | Satır 1 Veri 1 | Satır 1 Veri 2 | Satır 1 Veri 3 |
            | Satır 2 Veri 1 | Satır 2 Veri 2 | Satır 2 Veri 3 |
            | Satır 3 Veri 1 | Satır 3 Veri 2 | Satır 3 Veri 3 |
            """
        ),
        TablePreset(
            id: "comparison",
            titleTr: "Karşılaştırma (Artı / Eksi)",
            titleEn: "Comparison (Pros & Cons)",
            icon: "scalemass",
            columns: 4,
            rows: 3,
            markdown: """
            | Kriter / Özellik | Seçenek A | Seçenek B | Not / Karar |
            | :--- | :--- | :--- | :--- |
            | 💰 Maliyet | Düşük | Orta | A avantajlı |
            | ⚡ Hız & Performans | Yüksek | Çok Yüksek | B daha ölçeklenebilir |
            | 🛠️ Kurulum Kolaylığı | 1 Gün | 1 Hafta | A ile başlamak mantıklı |
            """
        ),
        TablePreset(
            id: "weekly_planner",
            titleTr: "Haftalık Planlayıcı",
            titleEn: "Weekly Schedule",
            icon: "calendar",
            columns: 3,
            rows: 5,
            markdown: """
            | Gün | Ana Hedef | Durum |
            | :--- | :--- | :---: |
            | Pazartesi | Sprint planlama & Hedefler | ⏳ Devam Ediyor |
            | Salı | Mimari tasarım & Kodlama | 📝 Bekliyor |
            | Çarşamba | Entegrasyon & Testler | 📝 Bekliyor |
            | Perşembe | Kod inceleme & Refactor | 📝 Bekliyor |
            | Cuma | Yayınlama & Canlıya Alma | 🚀 Hedef |
            """
        ),
        TablePreset(
            id: "budget_tracker",
            titleTr: "Bütçe & Harcama Takibi",
            titleEn: "Budget & Expense Tracker",
            icon: "dollarsign.circle",
            columns: 4,
            rows: 4,
            markdown: """
            | Kalem / Harcama | Kategori | Tutar (₺) | Durum |
            | :--- | :--- | ---: | :---: |
            | Cloud Sunucu & Veritabanı | Altyapı | 1.250 | ✅ Ödendi |
            | Alan Adı Yenileme | Domain | 450 | ✅ Ödendi |
            | Tasarım & Varlık Lisansı | Lisans | 800 | ⏳ Bekliyor |
            | **Toplam** | - | **2.500** | - |
            """
        ),
        TablePreset(
            id: "project_sprint",
            titleTr: "Proje / Sprint Görevleri",
            titleEn: "Sprint Task Tracker",
            icon: "checklist",
            columns: 4,
            rows: 4,
            markdown: """
            | Görev | Sorumlu | Öncelik | Durum |
            | :--- | :--- | :---: | :---: |
            | Tablo ekleme özelliği | @Efe | 🔴 Yüksek | ✅ Tamamlandı |
            | Markdown önizleme stili | @Tasarım | 🟡 Orta | ⏳ Sürüyor |
            | Birim test kapsamı | @QA | 🟢 Düşük | 📝 Bekliyor |
            | App Store sürümü hazırlığı | @Ekip | 🔴 Yüksek | 🚀 Hazır |
            """
        )
    ]
}
