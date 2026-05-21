@preconcurrency import Carbon
import Foundation

enum HotkeyError: Error {
    case eventHandlerInstallFailed(OSStatus)
    case registrationFailed(OSStatus)
}

final class HotkeyManager {
    static let hotkeySignature: OSType = 0x4F4E4550 // ONEP
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var onHotkeyPressed: (() -> Void)?

    deinit {
        unregister()
    }

    func register(configuration: HotkeyConfiguration, onPressed: @escaping () -> Void) throws {
        try installEventHandlerIfNeeded()
        unregister()

        let hotKeyID = EventHotKeyID(signature: Self.hotkeySignature, id: 1)
        let status = RegisterEventHotKey(
            UInt32(configuration.keyCode),
            configuration.modifiers.carbonFlags,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr else {
            throw HotkeyError.registrationFailed(status)
        }

        onHotkeyPressed = onPressed
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }

    private func installEventHandlerIfNeeded() throws {
        guard eventHandlerRef == nil else {
            return
        }

        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            onePanelHotkeyEventHandler,
            1,
            &eventSpec,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )

        guard status == noErr else {
            throw HotkeyError.eventHandlerInstallFailed(status)
        }
    }

    fileprivate func handleHotkeyPressed() {
        onHotkeyPressed?()
    }
}

private extension HotkeyConfiguration.Modifier {
    var carbonFlags: UInt32 {
        var flags: UInt32 = 0

        if contains(.command) {
            flags |= UInt32(cmdKey)
        }
        if contains(.control) {
            flags |= UInt32(controlKey)
        }
        if contains(.option) {
            flags |= UInt32(optionKey)
        }
        if contains(.shift) {
            flags |= UInt32(shiftKey)
        }

        return flags
    }
}

private func onePanelHotkeyEventHandler(
    _ nextHandler: EventHandlerCallRef?,
    _ eventRef: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard
        let userData,
        let eventRef
    else {
        return noErr
    }

    let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
        eventRef,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )

    guard status == noErr, hotKeyID.signature == HotkeyManager.hotkeySignature else {
        return noErr
    }

    manager.handleHotkeyPressed()
    return noErr
}
