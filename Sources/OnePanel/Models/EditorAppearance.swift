import AppKit
import Foundation
import SwiftUI

public struct EditorColor: Codable, Equatable, Sendable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public init(nsColor: NSColor) {
        let rgbColor = nsColor.usingColorSpace(.deviceRGB)
            ?? NSColor.labelColor.usingColorSpace(.deviceRGB)
            ?? NSColor.black

        self.init(
            red: Double(rgbColor.redComponent),
            green: Double(rgbColor.greenComponent),
            blue: Double(rgbColor.blueComponent),
            alpha: Double(rgbColor.alphaComponent)
        )
    }

    public var nsColor: NSColor {
        NSColor(
            calibratedRed: red,
            green: green,
            blue: blue,
            alpha: alpha
        )
    }
}

public enum EditorTextColor: Codable, Equatable, Sendable {
    case systemLabel
    case custom(EditorColor)

    public static let defaultValue: EditorTextColor = .systemLabel

    public var nsColor: NSColor {
        switch self {
        case .systemLabel:
            return .labelColor
        case let .custom(color):
            return color.nsColor
        }
    }

    public var swiftUIColor: Color {
        Color(nsColor: nsColor)
    }
}

public enum EditorFontWeight: String, Codable, CaseIterable, Sendable {
    case regular
    case medium
    case semibold
    case bold

    public var displayName: String {
        switch self {
        case .regular:
            return "Regular"
        case .medium:
            return "Medium"
        case .semibold:
            return "Semibold"
        case .bold:
            return "Bold"
        }
    }

    var nsFontWeight: NSFont.Weight {
        switch self {
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        }
    }

    var fontManagerWeight: Int {
        switch self {
        case .regular:
            return 5
        case .medium:
            return 6
        case .semibold:
            return 8
        case .bold:
            return 9
        }
    }
}

public struct EditorAppearance: Codable, Equatable, Sendable {
    public static let systemMonospacedIdentifier = "__SYSTEM_MONOSPACED__"

    public var fontFamilyName: String?
    public var fontSize: Double
    public var fontWeight: EditorFontWeight
    public var lineSpacing: Double
    public var textColor: EditorTextColor

    public init(
        fontFamilyName: String?,
        fontSize: Double,
        fontWeight: EditorFontWeight,
        lineSpacing: Double,
        textColor: EditorTextColor
    ) {
        self.fontFamilyName = fontFamilyName
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.lineSpacing = lineSpacing
        self.textColor = textColor
    }

    public static let defaultValue = EditorAppearance(
        fontFamilyName: nil,
        fontSize: Double(NSFont.systemFontSize),
        fontWeight: .regular,
        lineSpacing: 4,
        textColor: .defaultValue
    )

    @MainActor
    public func resolvedFont() -> NSFont {
        guard let fontFamilyName else {
            return NSFont.monospacedSystemFont(
                ofSize: CGFloat(fontSize),
                weight: fontWeight.nsFontWeight
            )
        }

        if let customFont = NSFontManager.shared.font(
            withFamily: fontFamilyName,
            traits: [],
            weight: fontWeight.fontManagerWeight,
            size: CGFloat(fontSize)
        ) {
            return customFont
        }

        if let fallbackFont = NSFont(name: fontFamilyName, size: CGFloat(fontSize)) {
            return fallbackFont
        }

        return NSFont.monospacedSystemFont(
            ofSize: CGFloat(fontSize),
            weight: fontWeight.nsFontWeight
        )
    }
}
