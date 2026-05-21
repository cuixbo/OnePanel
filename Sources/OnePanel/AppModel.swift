import Combine
import Foundation

@MainActor
public final class AppModel: ObservableObject {
    @Published public var documentText: String = ""
    @Published public private(set) var settings: AppSettings = .defaultValue
    @Published public private(set) var isPanelVisible = false

    private let documentStore: DocumentStore
    private let settingsStore: SettingsStore

    public init(documentStore: DocumentStore, settingsStore: SettingsStore) {
        self.documentStore = documentStore
        self.settingsStore = settingsStore
    }

    public func load() throws {
        documentText = try documentStore.load()
        settings = try settingsStore.load()
    }

    public func updateDocumentText(_ newValue: String) throws {
        documentText = newValue
        try documentStore.save(newValue)
    }

    public func togglePanelVisibility() {
        isPanelVisible.toggle()
    }

    public func setPanelVisibility(_ isVisible: Bool) {
        isPanelVisible = isVisible
    }

    public func setPinned(_ isPinned: Bool) throws {
        settings.isPinned = isPinned
        try settingsStore.save(settings)
    }

    public func saveWindowFrame(_ frame: WindowFrameState) throws {
        settings.lastWindowFrame = frame
        try settingsStore.save(settings)
    }

    public func updateHotkey(_ hotkey: HotkeyConfiguration) throws {
        settings.hotkey = hotkey
        try settingsStore.save(settings)
    }

    public func setRememberWindowState(_ shouldRemember: Bool) throws {
        settings.rememberWindowState = shouldRemember
        try settingsStore.save(settings)
    }

    public func setLaunchAtLogin(_ shouldLaunchAtLogin: Bool) throws {
        settings.launchAtLogin = shouldLaunchAtLogin
        try settingsStore.save(settings)
    }
}
