import AppKit
import Foundation

struct RunningApplicationSnapshot: Equatable {
    let processIdentifier: pid_t
    let bundleIdentifier: String?
}

protocol RunningApplicationQuery {
    func runningApplications(withBundleIdentifier bundleIdentifier: String) -> [RunningApplicationSnapshot]
}

struct SystemRunningApplicationQuery: RunningApplicationQuery {
    func runningApplications(withBundleIdentifier bundleIdentifier: String) -> [RunningApplicationSnapshot] {
        NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleIdentifier)
            .map {
                RunningApplicationSnapshot(
                    processIdentifier: $0.processIdentifier,
                    bundleIdentifier: $0.bundleIdentifier
                )
            }
    }
}

struct SingleInstanceCoordinator {
    let bundleIdentifier: String
    let currentProcessIdentifier: pid_t
    let runningApplicationQuery: RunningApplicationQuery

    init(
        bundleIdentifier: String,
        currentProcessIdentifier: pid_t = ProcessInfo.processInfo.processIdentifier,
        runningApplicationQuery: RunningApplicationQuery = SystemRunningApplicationQuery()
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.currentProcessIdentifier = currentProcessIdentifier
        self.runningApplicationQuery = runningApplicationQuery
    }

    func hasAnotherRunningInstance() -> Bool {
        runningApplicationQuery
            .runningApplications(withBundleIdentifier: bundleIdentifier)
            .contains { $0.processIdentifier != currentProcessIdentifier }
    }
}
