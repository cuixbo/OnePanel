import Foundation

public struct AppSettings: Codable, Equatable, Sendable {
    public var hotkey: HotkeyConfiguration
    public var rememberWindowState: Bool
    public var launchAtLogin: Bool
    public var isPinned: Bool
    public var lastWindowFrame: WindowFrameState?
    public var editorAppearance: EditorAppearance

    enum CodingKeys: String, CodingKey {
        case hotkey
        case rememberWindowState
        case launchAtLogin
        case isPinned
        case lastWindowFrame
        case editorAppearance
    }

    public init(
        hotkey: HotkeyConfiguration,
        rememberWindowState: Bool,
        launchAtLogin: Bool,
        isPinned: Bool,
        lastWindowFrame: WindowFrameState?,
        editorAppearance: EditorAppearance
    ) {
        self.hotkey = hotkey
        self.rememberWindowState = rememberWindowState
        self.launchAtLogin = launchAtLogin
        self.isPinned = isPinned
        self.lastWindowFrame = lastWindowFrame
        self.editorAppearance = editorAppearance
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hotkey = try container.decodeIfPresent(HotkeyConfiguration.self, forKey: .hotkey) ?? .defaultValue
        rememberWindowState = try container.decodeIfPresent(Bool.self, forKey: .rememberWindowState) ?? true
        launchAtLogin = try container.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? false
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        lastWindowFrame = try container.decodeIfPresent(WindowFrameState.self, forKey: .lastWindowFrame)
        editorAppearance = try container.decodeIfPresent(EditorAppearance.self, forKey: .editorAppearance) ?? .defaultValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hotkey, forKey: .hotkey)
        try container.encode(rememberWindowState, forKey: .rememberWindowState)
        try container.encode(launchAtLogin, forKey: .launchAtLogin)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encodeIfPresent(lastWindowFrame, forKey: .lastWindowFrame)
        try container.encode(editorAppearance, forKey: .editorAppearance)
    }

    public static let defaultValue = AppSettings(
        hotkey: .defaultValue,
        rememberWindowState: true,
        launchAtLogin: false,
        isPinned: false,
        lastWindowFrame: nil,
        editorAppearance: .defaultValue
    )
}
