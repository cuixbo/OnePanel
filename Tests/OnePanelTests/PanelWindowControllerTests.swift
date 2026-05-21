import AppKit
import Foundation
import Testing
@testable import OnePanel

@MainActor
struct PanelWindowControllerTests {
    @Test
    func preservesEditorTextAcrossHideAndShow() throws {
        let tempDir = try makeTemporaryDirectory()
        let documentURL = tempDir.appending(path: "document.txt")
        let model = AppModel(
            documentStore: DocumentStore(fileURL: documentURL),
            settingsStore: SettingsStore(fileURL: tempDir.appending(path: "settings.json"))
        )
        try model.load()

        let controller = PanelWindowController(
            model: model,
            onTogglePin: {},
            onOpenSettings: {}
        )

        controller.showPanel()

        let textView = try #require(findTextView(in: controller.panelWindowForTesting))
        textView.string = "123"
        textView.delegate?.textDidChange?(Notification(name: NSText.didChangeNotification, object: textView))

        controller.hidePanel()
        try model.load()
        controller.showPanel()

        #expect(try String(contentsOf: documentURL, encoding: .utf8) == "123")
        #expect(model.documentText == "123")
        #expect(findTextView(in: controller.panelWindowForTesting)?.string == "123")
    }

    @Test
    func configuresWindowTitleAndToolbarActions() throws {
        let tempDir = try makeTemporaryDirectory()
        let model = AppModel(
            documentStore: DocumentStore(fileURL: tempDir.appending(path: "document.txt")),
            settingsStore: SettingsStore(fileURL: tempDir.appending(path: "settings.json"))
        )

        let controller = PanelWindowController(
            model: model,
            onTogglePin: {},
            onOpenSettings: {}
        )

        controller.showPanel()

        let window = controller.panelWindowForTesting
        #expect(window.title == "OnePanel")
        #expect(window.titleVisibility == .visible)
        #expect(window.toolbar != nil)
        let identifiers = Set(window.toolbar?.items.map(\.itemIdentifier) ?? [])
        #expect(identifiers.contains(NSToolbarItem.Identifier("OnePanel.Toolbar.Pin")))
        #expect(identifiers.contains(NSToolbarItem.Identifier("OnePanel.Toolbar.Settings")))
    }

    @Test
    func togglePanelDoesNotHideVisiblePanelWhenAnotherWindowIsKey() throws {
        let tempDir = try makeTemporaryDirectory()
        let model = AppModel(
            documentStore: DocumentStore(fileURL: tempDir.appending(path: "document.txt")),
            settingsStore: SettingsStore(fileURL: tempDir.appending(path: "settings.json"))
        )

        let controller = PanelWindowController(
            model: model,
            onTogglePin: {},
            onOpenSettings: {}
        )
        controller.showPanel()

        let competingWindow = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 220, height: 120),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        competingWindow.makeKeyAndOrderFront(nil)

        controller.togglePanel()

        let panelWindow = controller.panelWindowForTesting
        #expect(model.isPanelVisible == true)
        #expect(panelWindow.isVisible == true)

        competingWindow.orderOut(nil)
    }

    @Test
    func restoresSavedWindowFrameOnFreshController() throws {
        let tempDir = try makeTemporaryDirectory()
        let settingsURL = tempDir.appending(path: "settings.json")
        let settingsStore = SettingsStore(fileURL: settingsURL)
        let savedFrame = WindowFrameState(x: 420, y: 360, width: 910, height: 510)

        try settingsStore.save(
            AppSettings(
                hotkey: .defaultValue,
                rememberWindowState: true,
                launchAtLogin: false,
                isPinned: false,
                lastWindowFrame: savedFrame
            )
        )

        let model = AppModel(
            documentStore: DocumentStore(fileURL: tempDir.appending(path: "document.txt")),
            settingsStore: settingsStore
        )
        try model.load()
        #expect(model.settings.rememberWindowState == true)
        #expect(model.settings.lastWindowFrame == savedFrame)

        let controller = PanelWindowController(
            model: model,
            onTogglePin: {},
            onOpenSettings: {}
        )

        controller.restoreSavedFrameIfNeeded()
        let restoredBeforeShow = controller.panelWindowForTesting.frame
        #expect(isClose(restoredBeforeShow.origin.x, to: savedFrame.x))
        #expect(isClose(restoredBeforeShow.origin.y, to: savedFrame.y))
        #expect(isClose(restoredBeforeShow.size.width, to: savedFrame.width))
        #expect(isClose(restoredBeforeShow.size.height, to: savedFrame.height))

        controller.showPanel()

        let restoredFrame = controller.panelWindowForTesting.frame
        #expect(isClose(restoredFrame.origin.x, to: savedFrame.x))
        #expect(isClose(restoredFrame.origin.y, to: savedFrame.y))
        #expect(isClose(restoredFrame.size.width, to: savedFrame.width))
        #expect(isClose(restoredFrame.size.height, to: savedFrame.height))
    }

    private func findTextView(in window: NSWindow) -> NSTextView? {
        guard let contentView = window.contentView else {
            return nil
        }

        return findTextView(in: contentView)
    }

    private func findTextView(in windows: [NSWindow]) -> NSTextView? {
        for window in windows.reversed() {
            if let contentView = window.contentView, let textView = findTextView(in: contentView) {
                return textView
            }
        }

        return nil
    }

    private func findTextView(in view: NSView) -> NSTextView? {
        if let textView = view as? NSTextView {
            return textView
        }

        for subview in view.subviews {
            if let textView = findTextView(in: subview) {
                return textView
            }
        }

        return nil
    }

    private func isClose(_ value: CGFloat, to expected: Double, tolerance: Double = 0.5) -> Bool {
        abs(Double(value) - expected) <= tolerance
    }
}
