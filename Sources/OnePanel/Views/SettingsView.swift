import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: AppModel
    let onApplyHotkey: (HotkeyConfiguration) -> Void
    let onSetLaunchAtLogin: (Bool) -> Void
    let onQuit: () -> Void

    @State private var displayKey = ""
    @State private var usesCommand = true
    @State private var usesControl = true
    @State private var usesOption = false
    @State private var usesShift = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                settingsSection(title: "快捷键") {
                    Text(hotkeyPreview)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(alignment: .center, spacing: 16) {
                        modifierToggle("Command", isOn: $usesCommand)
                        modifierToggle("Control", isOn: $usesControl)
                        modifierToggle("Option", isOn: $usesOption)
                        modifierToggle("Shift", isOn: $usesShift)

                        TextField("例如 P", text: $displayKey)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 88)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button("应用快捷键") {
                        applyHotkey()
                    }
                    .disabled(!canApplyHotkey)
                }

                settingsSection(title: "通用") {
                    Toggle(
                        "记住窗口大小与位置",
                        isOn: Binding(
                            get: { model.settings.rememberWindowState },
                            set: { newValue in
                                do {
                                    try model.setRememberWindowState(newValue)
                                } catch {
                                    NSLog("OnePanel failed to save settings: \(error.localizedDescription)")
                                }
                            }
                        )
                    )

                    Toggle(
                        "开机自动启动",
                        isOn: Binding(
                            get: { model.settings.launchAtLogin },
                            set: { newValue in
                                onSetLaunchAtLogin(newValue)
                            }
                        )
                    )
                }

                Divider()

                HStack {
                    Spacer()

                    Button("退出 OnePanel", role: .destructive) {
                        onQuit()
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear(perform: syncFromModel)
        .onChange(of: displayKey) { _, newValue in
            displayKey = String(newValue.uppercased().prefix(1))
        }
    }

    private var canApplyHotkey: Bool {
        !displayKey.isEmpty && (usesCommand || usesControl || usesOption || usesShift)
    }

    private var hotkeyPreview: String {
        let parts = [
            usesCommand ? "Command" : nil,
            usesControl ? "Control" : nil,
            usesOption ? "Option" : nil,
            usesShift ? "Shift" : nil,
            displayKey.isEmpty ? nil : displayKey
        ].compactMap { $0 }

        return parts.isEmpty ? "请输入一个有效快捷键" : parts.joined(separator: " + ")
    }

    private func syncFromModel() {
        displayKey = model.settings.hotkey.displayKey
        usesCommand = model.settings.hotkey.modifiers.contains(.command)
        usesControl = model.settings.hotkey.modifiers.contains(.control)
        usesOption = model.settings.hotkey.modifiers.contains(.option)
        usesShift = model.settings.hotkey.modifiers.contains(.shift)
    }

    private func applyHotkey() {
        guard canApplyHotkey else {
            return
        }

        var modifiers: HotkeyConfiguration.Modifier = []
        if usesCommand { modifiers.insert(.command) }
        if usesControl { modifiers.insert(.control) }
        if usesOption { modifiers.insert(.option) }
        if usesShift { modifiers.insert(.shift) }

        guard let hotkey = HotkeyConfiguration.from(displayKey: displayKey, modifiers: modifiers) else {
            return
        }

        onApplyHotkey(hotkey)
    }

    @ViewBuilder
    private func modifierToggle(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .fixedSize()
    }

    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
