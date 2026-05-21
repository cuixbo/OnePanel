import Foundation

public struct DocumentStore: Sendable {
    public let fileURL: URL
    public let backupFileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
        self.backupFileURL = fileURL
            .deletingPathExtension()
            .appendingPathExtension("backup")
            .appendingPathExtension(fileURL.pathExtension)
    }

    public func load() throws -> String {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return ""
        }

        return try String(contentsOf: fileURL, encoding: .utf8)
    }

    public func save(_ content: String) throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            let existingContent = try String(contentsOf: fileURL, encoding: .utf8)

            if existingContent != content {
                try existingContent.write(to: backupFileURL, atomically: true, encoding: .utf8)
            }
        }

        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
