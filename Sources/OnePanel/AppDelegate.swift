import AppKit
import Foundation

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let model = AppModel(
        documentStore: DocumentStore(fileURL: AppPaths.documentURL),
        settingsStore: SettingsStore(fileURL: AppPaths.settingsURL)
    )

    private let hotkeyManager = HotkeyManager()
    private let launchAtLoginManager = LaunchAtLoginManager()
    private let statusItemPanelPresenter = StatusItemPanelPresenter()
    private var panelController: PanelWindowController?
    private var settingsWindowController: SettingsWindowController?
    private var statusItem: NSStatusItem?
    private var statusMenu: NSMenu?
    private var launchDisposition: LaunchDisposition = .manual
    private var handledInitialPresentation = false

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleOpenApplicationEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kCoreEventClass),
            andEventID: AEEventID(kAEOpenApplication)
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        if shouldAbortLaunchBecauseAnotherInstanceIsRunning() {
            NSLog("OnePanel detected another running instance and will terminate this launch")
            NSApp.terminate(nil)
            return
        }

        reloadPersistedState()

        panelController = PanelWindowController(
            model: model,
            onTogglePin: { [weak self] in
                self?.togglePinned()
            },
            onOpenSettings: { [weak self] in
                self?.openSettings()
            }
        )
        panelController?.applyPinnedState(model.settings.isPinned)
        settingsWindowController = SettingsWindowController(
            model: model,
            onApplyHotkey: { [weak self] hotkey in
                self?.applyHotkey(hotkey)
            },
            onSetLaunchAtLogin: { [weak self] isEnabled in
                self?.setLaunchAtLogin(isEnabled)
            },
            onQuit: { [weak self] in
                self?.quitApp()
            }
        )
        setupStatusItem()
        applyHotkey(model.settings.hotkey)
        handleInitialPresentationIfNeeded()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showPanelForManualLaunch()
        return false
    }

    func applyHotkey(_ configuration: HotkeyConfiguration) {
        do {
            try model.updateHotkey(configuration)
            try hotkeyManager.register(configuration: configuration) { [weak self] in
                Task { @MainActor in
                    self?.togglePanel()
                }
            }
        } catch {
            NSLog("OnePanel failed to register hotkey: \(error.localizedDescription)")
        }
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = StatusBarIconFactory.makeTemplateImage()
        item.button?.imagePosition = .imageOnly
        item.button?.toolTip = "OnePanel"
        item.button?.action = #selector(handleStatusItemClick)
        item.button?.target = self
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        statusMenu = NSMenu()
        statusItem = item
    }

    @objc
    private func handleStatusItemClick() {
        guard let event = NSApp.currentEvent else {
            statusItemPanelPresenter.presentAfterStatusItemClick { [weak self] in
                self?.showPanelFromStatusItem()
            }
            return
        }

        switch event.type {
        case .rightMouseUp:
            showStatusMenu()
        default:
            statusItemPanelPresenter.presentAfterStatusItemClick { [weak self] in
                self?.showPanelFromStatusItem()
            }
        }
    }

    private func togglePanel() {
        if !model.isPanelVisible {
            panelController?.applyPinnedState(model.settings.isPinned)
        }

        panelController?.togglePanel()
    }

    private func togglePinned() {
        let newPinned = !model.settings.isPinned

        do {
            try model.setPinned(newPinned)
            panelController?.applyPinnedState(newPinned)
        } catch {
            NSLog("OnePanel failed to persist pin state: \(error.localizedDescription)")
        }
    }

    private func openSettings() {
        settingsWindowController?.showWindowAndActivate()
    }

    private func quitApp() {
        NSApp.terminate(nil)
    }

    private func setLaunchAtLogin(_ isEnabled: Bool) {
        do {
            try launchAtLoginManager.setEnabled(isEnabled)
            try model.setLaunchAtLogin(isEnabled)
        } catch {
            NSLog("OnePanel failed to update launch at login: \(error.localizedDescription)")
        }
    }

    private func showStatusMenu() {
        guard let statusItem, let button = statusItem.button, let statusMenu else {
            return
        }

        statusMenu.removeAllItems()

        for item in StatusMenuContent.makeItems(isPanelVisible: model.isPanelVisible) {
            let menuItem = NSMenuItem(title: item.title, action: #selector(handleStatusMenuSelection(_:)), keyEquivalent: "")
            menuItem.target = self
            menuItem.representedObject = item.action
            statusMenu.addItem(menuItem)
        }

        statusItem.menu = statusMenu
        button.performClick(nil)
        statusItem.menu = nil
    }

    private func showPanelForManualLaunch() {
        guard !model.isPanelVisible else {
            panelController?.showPanel()
            return
        }

        panelController?.applyPinnedState(model.settings.isPinned)
        panelController?.showPanel()
    }

    private func showPanelFromStatusItem() {
        panelController?.applyPinnedState(model.settings.isPinned)
        panelController?.showPanel()
    }

    private func handleInitialPresentationIfNeeded() {
        guard !handledInitialPresentation else {
            return
        }

        handledInitialPresentation = true

        guard launchDisposition == .manual else {
            return
        }

        showPanelForManualLaunch()
    }

    private func reloadPersistedState() {
        do {
            try model.load()
        } catch {
            NSLog("OnePanel failed to load persisted state: \(error.localizedDescription)")
        }
    }

    private func shouldAbortLaunchBecauseAnotherInstanceIsRunning() -> Bool {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return false
        }

        let coordinator = SingleInstanceCoordinator(bundleIdentifier: bundleIdentifier)
        return coordinator.hasAnotherRunningInstance()
    }

    @objc
    private func handleStatusMenuSelection(_ sender: NSMenuItem) {
        guard let action = sender.representedObject as? StatusMenuItem.Action else {
            return
        }

        switch action {
        case .togglePanel:
            togglePanel()
        case .openSettings:
            openSettings()
        case .quit:
            quitApp()
        }
    }

    @objc
    private func handleOpenApplicationEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        launchDisposition = LaunchDispositionClassifier.disposition(for: event)

        if panelController != nil {
            handleInitialPresentationIfNeeded()
        }
    }
}
