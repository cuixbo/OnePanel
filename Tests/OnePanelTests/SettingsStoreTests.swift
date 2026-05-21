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
            lastWindowFrame: state,
            editorAppearance: EditorAppearance(
                fontFamilyName: "Helvetica",
                fontSize: 18,
                fontWeight: .semibold,
                lineSpacing: 6,
                textColor: .custom(EditorColor(red: 0.12, green: 0.34, blue: 0.56, alpha: 1))
            )
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
            lastWindowFrame: WindowFrameState(x: 88, y: 120, width: 777, height: 555),
            editorAppearance: EditorAppearance(
                fontFamilyName: nil,
                fontSize: 17,
                fontWeight: .regular,
                lineSpacing: 4,
                textColor: .systemLabel
            )
        )

        try store.save(expected)

        #expect(try store.load() == expected)
    }

    @Test
    func loadsLegacySettingsWithoutEditorAppearanceUsingDefaults() throws {
        let tempDir = try makeTemporaryDirectory()
        let fileURL = tempDir.appending(path: "settings.json")
        let legacyJSON = """
        {
          "hotkey": {
            "keyCode": 35,
            "modifiers": 3
          },
          "rememberWindowState": false,
          "launchAtLogin": true,
          "isPinned": true,
          "lastWindowFrame": {
            "x": 12,
            "y": 34,
            "width": 640,
            "height": 480
          }
        }
        """
        try legacyJSON.write(to: fileURL, atomically: true, encoding: .utf8)

        let settings = try SettingsStore(fileURL: fileURL).load()

        #expect(settings.editorAppearance == .defaultValue)
        #expect(settings.launchAtLogin == true)
        #expect(settings.isPinned == true)
    }
}
