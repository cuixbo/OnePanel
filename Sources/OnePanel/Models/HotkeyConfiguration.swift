import Foundation

public struct HotkeyConfiguration: Codable, Equatable, Sendable {
    public struct Modifier: OptionSet, Codable, Equatable, Sendable {
        public let rawValue: Int

        public static let command = Modifier(rawValue: 1 << 0)
        public static let control = Modifier(rawValue: 1 << 1)
        public static let option = Modifier(rawValue: 1 << 2)
        public static let shift = Modifier(rawValue: 1 << 3)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    public var keyCode: Int
    public var modifiers: Modifier

    public init(keyCode: Int, modifiers: Modifier) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    public static let defaultValue = HotkeyConfiguration(
        keyCode: 35,
        modifiers: [.command, .control]
    )

    public var displayKey: String {
        Self.displayKey(for: keyCode) ?? String(keyCode)
    }

    public static func from(displayKey: String, modifiers: Modifier) -> HotkeyConfiguration? {
        guard let keyCode = keyCode(for: displayKey) else {
            return nil
        }

        return HotkeyConfiguration(keyCode: keyCode, modifiers: modifiers)
    }

    private static let keyCodeMap: [String: Int] = [
        "A": 0, "S": 1, "D": 2, "F": 3, "H": 4, "G": 5, "Z": 6, "X": 7, "C": 8, "V": 9,
        "B": 11, "Q": 12, "W": 13, "E": 14, "R": 15, "Y": 16, "T": 17, "1": 18, "2": 19,
        "3": 20, "4": 21, "6": 22, "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28,
        "0": 29, "]": 30, "O": 31, "U": 32, "[": 33, "I": 34, "P": 35, "L": 37, "J": 38,
        "'": 39, "K": 40, ";": 41, "\\": 42, ",": 43, "/": 44, "N": 45, "M": 46, ".": 47
    ]

    private static let displayKeyMap = Dictionary(uniqueKeysWithValues: keyCodeMap.map { ($1, $0) })

    private static func keyCode(for displayKey: String) -> Int? {
        keyCodeMap[displayKey.uppercased()]
    }

    private static func displayKey(for keyCode: Int) -> String? {
        displayKeyMap[keyCode]
    }
}
