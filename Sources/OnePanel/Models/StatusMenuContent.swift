import Foundation

struct StatusMenuItem: Equatable, Sendable {
    enum Action: Sendable {
        case togglePanel
        case openSettings
        case quit
    }

    let title: String
    let action: Action
}

enum StatusMenuContent {
    static func makeItems(isPanelVisible: Bool) -> [StatusMenuItem] {
        [
            StatusMenuItem(
                title: isPanelVisible ? "隐藏 OnePanel" : "打开 OnePanel",
                action: .togglePanel
            ),
            StatusMenuItem(
                title: "设置",
                action: .openSettings
            ),
            StatusMenuItem(
                title: "退出 OnePanel",
                action: .quit
            )
        ]
    }
}
