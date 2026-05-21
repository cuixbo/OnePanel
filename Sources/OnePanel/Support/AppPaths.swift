import Foundation

enum AppPaths {
    private static let appDirectoryName = "OnePanel"

    static var applicationSupportDirectory: URL {
        let baseDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.homeDirectoryForCurrentUser.appending(path: "Library/Application Support")
        return baseDirectory.appending(path: appDirectoryName)
    }

    static var documentURL: URL {
        applicationSupportDirectory.appending(path: "document.txt")
    }

    static var settingsURL: URL {
        applicationSupportDirectory.appending(path: "settings.json")
    }
}
