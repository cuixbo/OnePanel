import AppKit
import Foundation
import Testing
@testable import OnePanel

@MainActor
struct SettingsWindowControllerTests {
    @Test
    func usesLargerDefaultWindowSize() throws {
        let tempDir = try makeTemporaryDirectory()
        let model = AppModel(
            documentStore: DocumentStore(fileURL: tempDir.appending(path: "document.txt")),
            settingsStore: SettingsStore(fileURL: tempDir.appending(path: "settings.json"))
        )

        let controller = SettingsWindowController(
            model: model,
            onApplyHotkey: { _ in },
            onSetLaunchAtLogin: { _ in },
            onQuit: {}
        )

        #expect(SettingsWindowController.defaultWindowRect.width == 600)
        #expect(SettingsWindowController.defaultWindowRect.height == 540)
        #expect(SettingsWindowController.defaultContentSize.width == 560)
        #expect(SettingsWindowController.defaultContentSize.height == 500)
        let window = try #require(controller.window)
        #expect(window.styleMask.contains(.resizable))
        #expect(window.contentMinSize.width == 560)
        #expect(window.contentMinSize.height == 500)
    }
}
