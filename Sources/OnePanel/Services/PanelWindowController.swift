import AppKit
import SwiftUI

@MainActor
final class PanelWindowController: NSObject, NSWindowDelegate, NSToolbarDelegate {
    private let model: AppModel
    private let onTogglePin: () -> Void
    private let onOpenSettings: () -> Void
    private let window: PanelWindow
    private var canPersistWindowFrame = false
    private lazy var pinToolbarItem = makeToolbarButtonItem(
        identifier: .pin,
        imageName: model.settings.isPinned ? "pin.fill" : "pin",
        action: #selector(togglePinFromToolbar),
        toolTip: model.settings.isPinned ? "取消固定" : "固定窗口"
    )
    private lazy var settingsToolbarItem = makeToolbarButtonItem(
        identifier: .settings,
        imageName: "gearshape",
        action: #selector(openSettingsFromToolbar),
        toolTip: "打开设置"
    )

    init(
        model: AppModel,
        onTogglePin: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self.model = model
        self.onTogglePin = onTogglePin
        self.onOpenSettings = onOpenSettings
        self.window = PanelWindow(
            contentRect: NSRect(x: 240, y: 240, width: 720, height: 560),
            styleMask: [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        super.init()
        configureWindow()
    }

    func togglePanel() {
        if shouldHidePanelOnToggle {
            hidePanel()
        } else {
            showPanel()
        }
    }

    func showPanel() {
        if model.settings.rememberWindowState {
            restoreSavedFrameIfNeeded()
        }

        NSRunningApplication.current.activate(options: [.activateAllWindows])
        NSApp.activate(ignoringOtherApps: true)
        window.orderFrontRegardless()
        window.order(.above, relativeTo: 0)
        window.makeKeyAndOrderFront(nil)
        window.makeMain()
        window.makeFirstResponder(window.contentView)
        canPersistWindowFrame = true
        model.setPanelVisibility(true)
    }

    func hidePanel() {
        window.orderOut(nil)
        model.setPanelVisibility(false)
    }

    func applyPinnedState(_ isPinned: Bool) {
        window.level = isPinned ? .floating : .normal
        window.collectionBehavior = isPinned
            ? [.canJoinAllSpaces, .fullScreenAuxiliary]
            : [.moveToActiveSpace, .fullScreenAuxiliary]
        refreshPinToolbarItem()
    }

    func restoreSavedFrameIfNeeded() {
        guard let frameState = model.settings.lastWindowFrame else {
            return
        }

        let frame = NSRect(
            x: frameState.x,
            y: frameState.y,
            width: max(frameState.width, 360),
            height: max(frameState.height, 280)
        )
        window.setFrame(frame, display: true)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        hidePanel()
        return false
    }

    func windowDidMove(_ notification: Notification) {
        persistWindowFrameIfNeeded()
    }

    func windowDidResize(_ notification: Notification) {
        persistWindowFrameIfNeeded()
    }

    var panelWindowForTesting: NSWindow {
        window
    }

    private func configureWindow() {
        window.onEscape = { [weak self] in
            self?.hidePanel()
        }
        window.title = "OnePanel"
        window.isReleasedWhenClosed = false
        window.isOpaque = false
        window.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.94)
        window.hasShadow = true
        window.contentMinSize = NSSize(width: 360, height: 280)
        window.delegate = self
        applyPinnedState(model.settings.isPinned)
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = true
        window.toolbarStyle = .unifiedCompact
        configureToolbar()
        let hostingController = NSHostingController(
            rootView: PanelRootView(
                model: model,
                onExit: { [weak self] in
                    self?.hidePanel()
                }
            )
        )
        hostingController.sizingOptions = []
        window.contentViewController = hostingController
    }

    private var shouldHidePanelOnToggle: Bool {
        model.isPanelVisible && window.isVisible && NSApp.isActive && window.isKeyWindow
    }

    private func persistWindowFrameIfNeeded() {
        guard canPersistWindowFrame, model.settings.rememberWindowState else {
            return
        }

        let frame = window.frame

        do {
            try model.saveWindowFrame(
                WindowFrameState(
                    x: frame.origin.x,
                    y: frame.origin.y,
                    width: frame.size.width,
                    height: frame.size.height
                )
            )
        } catch {
            NSLog("OnePanel failed to persist window frame: \(error.localizedDescription)")
        }
    }

    private func configureToolbar() {
        let toolbar = NSToolbar(identifier: "OnePanel.PanelToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = false
        if #available(macOS 15.0, *) {
            toolbar.showsBaselineSeparator = false
        }
        window.toolbar = toolbar
        refreshPinToolbarItem()
    }

    private func makeToolbarButtonItem(
        identifier: NSToolbarItem.Identifier,
        imageName: String,
        action: Selector,
        toolTip: String
    ) -> NSToolbarItem {
        let button = NSButton(image: NSImage(systemSymbolName: imageName, accessibilityDescription: toolTip) ?? NSImage(), target: self, action: action)
        button.bezelStyle = .texturedRounded
        button.isBordered = false
        button.imageScaling = .scaleProportionallyDown
        button.contentTintColor = .labelColor
        button.toolTip = toolTip

        let item = NSToolbarItem(itemIdentifier: identifier)
        item.view = button
        item.label = toolTip
        item.paletteLabel = toolTip
        item.toolTip = toolTip
        return item
    }

    private func refreshPinToolbarItem() {
        guard let button = pinToolbarItem.view as? NSButton else {
            return
        }

        let isPinned = model.settings.isPinned
        button.image = NSImage(
            systemSymbolName: isPinned ? "pin.fill" : "pin",
            accessibilityDescription: isPinned ? "取消固定" : "固定窗口"
        )
        button.toolTip = isPinned ? "取消固定" : "固定窗口"
        pinToolbarItem.label = isPinned ? "取消固定" : "固定窗口"
        pinToolbarItem.paletteLabel = pinToolbarItem.label
        pinToolbarItem.toolTip = pinToolbarItem.label
    }

    @objc
    private func togglePinFromToolbar() {
        onTogglePin()
    }

    @objc
    private func openSettingsFromToolbar() {
        onOpenSettings()
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.flexibleSpace, .pin, .settings]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.flexibleSpace, .pin, .settings]
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .pin:
            return pinToolbarItem
        case .settings:
            return settingsToolbarItem
        default:
            return nil
        }
    }
}

@MainActor
private final class PanelWindow: NSWindow {
    var onEscape: (() -> Void)?

    override var canBecomeKey: Bool { true }

    override func cancelOperation(_ sender: Any?) {
        onEscape?()
    }
}

private extension NSToolbarItem.Identifier {
    static let pin = NSToolbarItem.Identifier("OnePanel.Toolbar.Pin")
    static let settings = NSToolbarItem.Identifier("OnePanel.Toolbar.Settings")
}
