import Foundation
import ServiceManagement

enum LaunchAtLoginError: Error {
    case unsupportedBundle
}

@MainActor
final class LaunchAtLoginManager {
    func setEnabled(_ isEnabled: Bool) throws {
        guard Bundle.main.bundleURL.pathExtension == "app" else {
            throw LaunchAtLoginError.unsupportedBundle
        }

        if isEnabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}
