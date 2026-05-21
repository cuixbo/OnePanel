import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController {
    static let defaultContentSize = NSSize(width: 520, height: 380)
    static let defaultWindowRect = NSRect(x: 320, y: 320, width: 560, height: 420)

    init(
        model: AppModel,
        onApplyHotkey: @escaping (HotkeyConfiguration) -> Void,
        onSetLaunchAtLogin: @escaping (Bool) -> Void,
        onQuit: @escaping () -> Void
    ) {
        let hostingController = NSHostingController(
            rootView: SettingsView(
                model: model,
                onApplyHotkey: onApplyHotkey,
                onSetLaunchAtLogin: onSetLaunchAtLogin,
                onQuit: onQuit
            )
            .frame(
                minWidth: Self.defaultContentSize.width,
                minHeight: Self.defaultContentSize.height
            )
        )

        let window = NSWindow(
            contentRect: Self.defaultWindowRect,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "OnePanel 设置"
        window.isReleasedWhenClosed = false
        window.contentMinSize = Self.defaultContentSize
        window.contentViewController = hostingController
        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showWindowAndActivate() {
        showWindow(nil)
        window?.centerIfNeeded()
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}

private extension NSWindow {
    func centerIfNeeded() {
        guard !isVisible else {
            return
        }

        center()
    }
}
