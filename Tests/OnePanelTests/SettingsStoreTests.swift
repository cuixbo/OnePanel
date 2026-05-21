import Foundation
import Testing
@testable import OnePanel

struct SettingsStoreTests {
    @Test
    func returnsDefaultSettingsWhenFileDoesNotExist() throws {
        let tempDir = try makeTemporaryDirectory()
        let fileURL = tempDir.appending(path: "settings.json")
        let store = SettingsStore(fileURL: fileURL)

        #expect(try store.load() == .defaultValue)
    }

    @Test
    func savesAndLoadsSettingsRoundTrip() throws {
        let tempDir = try makeTemporaryDirectory()
        let fileURL = tempDir.appending(path: "settings.json")
        let store = SettingsStore(fileURL: fileURL)
        let state = WindowFrameState(x: 40, y: 50, width: 900, height: 640)
        let hotkey = HotkeyConfiguration(keyCode: 35, modifiers: [.command, .control])
        let expected = AppSettings(
            hotkey: hotkey,
            rememberWindowState: true,
            launchAtLogin: true,
            isPinned: true,
            lastWindowFrame: state
        )

        try store.save(expected)

        #expect(try store.load() == expected)
    }

    @Test
    func loadsSettingsFromPathContainingSpaces() throws {
        let tempDir = try makeTemporaryDirectory()
        let folderURL = tempDir.appending(path: "Folder With Space")
        let fileURL = folderURL.appending(path: "settings.json")
        let store = SettingsStore(fileURL: fileURL)
        let expected = AppSettings(
            hotkey: .defaultValue,
            rememberWindowState: false,
            launchAtLogin: true,
            isPinned: false,
            lastWindowFrame: WindowFrameState(x: 88, y: 120, width: 777, height: 555)
        )

        try store.save(expected)

        #expect(try store.load() == expected)
    }
}
