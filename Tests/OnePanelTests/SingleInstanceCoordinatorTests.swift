import Foundation
import Testing
@testable import OnePanel

struct SingleInstanceCoordinatorTests {
    @Test
    func returnsFalseWhenCurrentProcessIsOnlyInstance() {
        let coordinator = SingleInstanceCoordinator(
            bundleIdentifier: "com.onepanel.app",
            currentProcessIdentifier: 42,
            runningApplicationQuery: StubRunningApplicationQuery(
                snapshots: [
                    RunningApplicationSnapshot(processIdentifier: 42, bundleIdentifier: "com.onepanel.app")
                ]
            )
        )

        #expect(coordinator.hasAnotherRunningInstance() == false)
    }

    @Test
    func returnsTrueWhenAnotherProcessWithSameBundleIdentifierExists() {
        let coordinator = SingleInstanceCoordinator(
            bundleIdentifier: "com.onepanel.app",
            currentProcessIdentifier: 42,
            runningApplicationQuery: StubRunningApplicationQuery(
                snapshots: [
                    RunningApplicationSnapshot(processIdentifier: 42, bundleIdentifier: "com.onepanel.app"),
                    RunningApplicationSnapshot(processIdentifier: 99, bundleIdentifier: "com.onepanel.app")
                ]
            )
        )

        #expect(coordinator.hasAnotherRunningInstance() == true)
    }
}

private struct StubRunningApplicationQuery: RunningApplicationQuery {
    let snapshots: [RunningApplicationSnapshot]

    func runningApplications(withBundleIdentifier bundleIdentifier: String) -> [RunningApplicationSnapshot] {
        snapshots.filter { $0.bundleIdentifier == bundleIdentifier }
    }
}
