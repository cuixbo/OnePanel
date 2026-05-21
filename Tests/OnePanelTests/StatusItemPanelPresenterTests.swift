import Foundation
import Testing
@testable import OnePanel

@MainActor
struct StatusItemPanelPresenterTests {
    @Test
    func defersPanelPresentationUntilSchedulerRuns() {
        var scheduledAction: (@MainActor () -> Void)?
        let presenter = StatusItemPanelPresenter { action in
            scheduledAction = action
        }
        var didPresent = false

        presenter.presentAfterStatusItemClick {
            didPresent = true
        }

        #expect(didPresent == false)
        if let scheduledAction {
            scheduledAction()
        }
        #expect(scheduledAction != nil)
        #expect(didPresent == true)
    }
}
