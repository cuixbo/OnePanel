import Foundation

public struct AppSettings: Codable, Equatable, Sendable {
    public var hotkey: HotkeyConfiguration
    public var rememberWindowState: Bool
    public var launchAtLogin: Bool
    public var isPinned: Bool
    public var lastWindowFrame: WindowFrameState?

    public init(
        hotkey: HotkeyConfiguration,
        rememberWindowState: Bool,
        launchAtLogin: Bool,
        isPinned: Bool,
        lastWindowFrame: WindowFrameState?
    ) {
        self.hotkey = hotkey
        self.rememberWindowState = rememberWindowState
        self.launchAtLogin = launchAtLogin
        self.isPinned = isPinned
        self.lastWindowFrame = lastWindowFrame
    }

    public static let defaultValue = AppSettings(
        hotkey: .defaultValue,
        rememberWindowState: true,
        launchAtLogin: false,
        isPinned: false,
        lastWindowFrame: nil
    )
}
