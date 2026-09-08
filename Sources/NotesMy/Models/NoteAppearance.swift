import SwiftUI

public enum FontFamilyOption: String, Codable, CaseIterable, Identifiable, Sendable {
    case rounded = "System Rounded"
    case modern = "San Francisco (Modern)"
    case handwriting = "Caveat / Handwriting"
    case monospace = "Monospaced (Code)"
    case serif = "New York (Serif)"

    public var id: String { rawValue }

    public func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch self {
        case .rounded:
            return .system(size: size, weight: weight, design: .rounded)
        case .modern:
            return .system(size: size, weight: weight, design: .default)
        case .handwriting:
            return .custom("Caveat", size: size + 2).weight(weight)
        case .monospace:
            return .system(size: size, weight: weight, design: .monospaced)
        case .serif:
            return .system(size: size, weight: weight, design: .serif)
        }
    }
}

public enum CardSizeOption: String, Codable, CaseIterable, Identifiable, Sendable {
    case compact = "Compact (340 × 360)"
    case standard = "Standard (380 × 420)"
    case large = "Spacious (460 × 520)"

    public var id: String { rawValue }

    public var dimensions: (width: CGFloat, height: CGFloat) {
        switch self {
        case .compact: return (340, 360)
        case .standard: return (380, 420)
        case .large: return (460, 520)
        }
    }
}
