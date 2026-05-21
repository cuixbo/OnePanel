import Foundation
import Testing
@testable import OnePanel

@MainActor
struct AppModelTests {
    @Test
    func loadsDefaultStateFromMissingFiles() throws {
        let tempDir = try makeTemporaryDirectory()
        let model = AppModel(
            documentStore: DocumentStore(fileURL: tempDir.appending(path: "document.txt")),
            settingsStore: SettingsStore(fileURL: tempDir.appending(path: "settings.json"))
        )

        try model.load()

        #expect(model.documentText == "")
        #expect(model.isPanelVisible == false)
        #expect(model.settings == .defaultValue)
    }

    @Test
    func persistsDocumentTextWhenUpdated() throws {
        let tempDir = try makeTemporaryDirectory()
        let documentURL = tempDir.appending(path: "document.txt")
        let model = AppModel(
            documentStore: DocumentStore(fileURL: documentURL),
            settingsStore: SettingsStore(fileURL: tempDir.appending(path: "settings.json"))
        )

        try model.updateDocumentText("docker ps")

        #expect(try String(contentsOf: documentURL, encoding: .utf8) == "docker ps")
    }

    @Test
    func loadsExistingDocumentText() throws {
        let tempDir = try makeTemporaryDirectory()
        let documentURL = tempDir.appending(path: "document.txt")
        try "git status\nnpm test".write(to: documentURL, atomically: true, encoding: .utf8)

        let model = AppModel(
            documentStore: DocumentStore(fileURL: documentURL),
            settingsStore: SettingsStore(fileURL: tempDir.appending(path: "settings.json"))
        )

        try model.load()

        #expect(model.documentText == "git status\nnpm test")
    }

    @Test
    func loadRefreshesInMemoryDocumentTextFromDisk() throws {
        let tempDir = try makeTemporaryDirectory()
        let documentURL = tempDir.appending(path: "document.txt")
        try "first version".write(to: documentURL, atomically: true, encoding: .utf8)

        let model = AppModel(
            documentStore: DocumentStore(fileURL: documentURL),
            settingsStore: SettingsStore(fileURL: tempDir.appending(path: "settings.json"))
        )

        try model.load()
        try "second version".write(to: documentURL, atomically: true, encoding: .utf8)

        try model.load()

        #expect(model.documentText == "second version")
    }

    @Test
    func togglesPanelVisibility() throws {
        let tempDir = try makeTemporaryDirectory()
        let model = AppModel(
            documentStore: DocumentStore(fileURL: tempDir.appending(path: "document.txt")),
            settingsStore: SettingsStore(fileURL: tempDir.appending(path: "settings.json"))
        )

        model.togglePanelVisibility()
        #expect(model.isPanelVisible == true)

        model.togglePanelVisibility()
        #expect(model.isPanelVisible == false)
    }

    @Test
    func persistsPinnedStateAndWindowFrame() throws {
        let tempDir = try makeTemporaryDirectory()
        let settingsURL = tempDir.appending(path: "settings.json")
        let model = AppModel(
            documentStore: DocumentStore(fileURL: tempDir.appending(path: "document.txt")),
            settingsStore: SettingsStore(fileURL: settingsURL)
        )

        try model.setPinned(true)
        try model.saveWindowFrame(WindowFrameState(x: 10, y: 20, width: 800, height: 600))

        let reloaded = try SettingsStore(fileURL: settingsURL).load()
        #expect(reloaded.isPinned == true)
        #expect(reloaded.lastWindowFrame == WindowFrameState(x: 10, y: 20, width: 800, height: 600))
    }

    @Test
    func persistsLaunchAtLoginPreference() throws {
        let tempDir = try makeTemporaryDirectory()
        let settingsURL = tempDir.appending(path: "settings.json")
        let model = AppModel(
            documentStore: DocumentStore(fileURL: tempDir.appending(path: "document.txt")),
            settingsStore: SettingsStore(fileURL: settingsURL)
        )

        try model.setLaunchAtLogin(true)

        let reloaded = try SettingsStore(fileURL: settingsURL).load()
        #expect(reloaded.launchAtLogin == true)
    }

    @Test
    func persistsRememberWindowStatePreference() throws {
        let tempDir = try makeTemporaryDirectory()
        let settingsURL = tempDir.appending(path: "settings.json")
        let model = AppModel(
            documentStore: DocumentStore(fileURL: tempDir.appending(path: "document.txt")),
            settingsStore: SettingsStore(fileURL: settingsURL)
        )

        try model.setRememberWindowState(false)

        let reloaded = try SettingsStore(fileURL: settingsURL).load()
        #expect(reloaded.rememberWindowState == false)
    }

    @Test
    func persistsEditorAppearancePreferences() throws {
        let tempDir = try makeTemporaryDirectory()
        let settingsURL = tempDir.appending(path: "settings.json")
        let model = AppModel(
            documentStore: DocumentStore(fileURL: tempDir.appending(path: "document.txt")),
            settingsStore: SettingsStore(fileURL: settingsURL)
        )

        try model.setEditorFontFamily("Helvetica")
        try model.setEditorFontSize(20)
        try model.setEditorFontWeight(.bold)
        try model.setEditorLineSpacing(8)
        try model.setEditorTextColor(.custom(EditorColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)))

        let reloaded = try SettingsStore(fileURL: settingsURL).load()
        #expect(reloaded.editorAppearance.fontFamilyName == "Helvetica")
        #expect(reloaded.editorAppearance.fontSize == 20)
        #expect(reloaded.editorAppearance.fontWeight == .bold)
        #expect(reloaded.editorAppearance.lineSpacing == 8)
        #expect(reloaded.editorAppearance.textColor == .custom(EditorColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)))
    }
}
