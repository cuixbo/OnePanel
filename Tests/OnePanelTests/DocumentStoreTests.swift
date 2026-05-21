import Foundation
import Testing
@testable import OnePanel

struct DocumentStoreTests {
    @Test
    func loadsEmptyStringWhenDocumentDoesNotExist() throws {
        let tempDir = try makeTemporaryDirectory()
        let fileURL = tempDir.appending(path: "document.txt")
        let store = DocumentStore(fileURL: fileURL)

        #expect(try store.load() == "")
    }

    @Test
    func savesAndLoadsDocumentContent() throws {
        let tempDir = try makeTemporaryDirectory()
        let fileURL = tempDir.appending(path: "document.txt")
        let store = DocumentStore(fileURL: fileURL)
        let expected = "git status\nswift build\n"

        try store.save(expected)

        #expect(try store.load() == expected)
    }

    @Test
    func keepsPreviousVersionAsBackupBeforeOverwrite() throws {
        let tempDir = try makeTemporaryDirectory()
        let fileURL = tempDir.appending(path: "document.txt")
        let backupURL = tempDir.appending(path: "document.backup.txt")
        let store = DocumentStore(fileURL: fileURL)

        try store.save("first version")
        try store.save("second version")

        #expect(try String(contentsOf: fileURL, encoding: .utf8) == "second version")
        #expect(try String(contentsOf: backupURL, encoding: .utf8) == "first version")
    }

    @Test
    func loadsDocumentFromPathContainingSpaces() throws {
        let tempDir = try makeTemporaryDirectory()
        let folderURL = tempDir.appending(path: "Folder With Space")
        let fileURL = folderURL.appending(path: "document.txt")
        let store = DocumentStore(fileURL: fileURL)

        try store.save("persisted text")

        #expect(try store.load() == "persisted text")
    }
}
