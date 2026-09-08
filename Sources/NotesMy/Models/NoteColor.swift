import SwiftUI

public enum NoteColor: String, Codable, CaseIterable, Identifiable, Sendable {
    case amber = "amber"
    case coral = "coral"
    case mint = "mint"
    case sky = "sky"
    case lavender = "lavender"
    case slate = "slate"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .amber: return "Amber Yellow"
        case .coral: return "Coral Pink"
        case .mint: return "Mint Green"
        case .sky: return "Sky Blue"
        case .lavender: return "Lavender"
        case .slate: return "Slate Noir"
        }
    }

    public var backgroundHex: String {
        switch self {
        case .amber: return "#FFF6D6"
        case .coral: return "#FFE4E1"
        case .mint: return "#E3F8EB"
        case .sky: return "#E0F2FE"
        case .lavender: return "#F2E8FF"
        case .slate: return "#27272A"
        }
    }

    public var cardHex: String {
        switch self {
        case .amber: return "#FEF08A"
        case .coral: return "#FECDD3"
        case .mint: return "#BBF7D0"
        case .sky: return "#BAE6FD"
        case .lavender: return "#E9D5FF"
        case .slate: return "#3F3F46"
        }
    }

    public var dotHex: String {
        switch self {
        case .amber: return "#EAB308"
        case .coral: return "#F43F5E"
        case .mint: return "#10B981"
        case .sky: return "#0EA5E9"
        case .lavender: return "#A855F7"
        case .slate: return "#71717A"
        }
    }

    public var textColor: Color {
        switch self {
        case .slate:
            return Color(hex: "#F4F4F5")
        default:
            return Color(hex: "#1F2937")
        }
    }

    public var secondaryTextColor: Color {
        switch self {
        case .slate:
            return Color(hex: "#A1A1AA")
        default:
            return Color(hex: "#6B7280")
        }
    }

    public var primaryColor: Color {
        Color(hex: backgroundHex)
    }

    public var cardColor: Color {
        Color(hex: cardHex)
    }

    public var dotColor: Color {
        Color(hex: dotHex)
    }

    public var borderTone: Color {
        switch self {
        case .slate:
            return Color.white.opacity(0.12)
        default:
            return Color.black.opacity(0.08)
        }
    }
}

public extension Color {
    init(hex: String) {
        let hexClean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexClean).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexClean.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
