import AppKit
import CoreServices
import Foundation
import Testing
@testable import OnePanel

struct LaunchDispositionTests {
    @Test
    func treatsOpenApplicationEventWithoutLoginItemFlagAsManualLaunch() {
        let event = NSAppleEventDescriptor.appleEvent(
            withEventClass: AEEventClass(kCoreEventClass),
            eventID: AEEventID(kAEOpenApplication),
            targetDescriptor: nil,
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )

        #expect(LaunchDispositionClassifier.disposition(for: event) == .manual)
    }

    @Test
    func treatsOpenApplicationEventWithLoginItemFlagAsLoginItemLaunch() {
        let event = NSAppleEventDescriptor.appleEvent(
            withEventClass: AEEventClass(kCoreEventClass),
            eventID: AEEventID(kAEOpenApplication),
            targetDescriptor: nil,
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )
        event.setParam(
            NSAppleEventDescriptor(boolean: true),
            forKeyword: AEKeyword(keyAELaunchedAsLogInItem)
        )

        #expect(LaunchDispositionClassifier.disposition(for: event) == .loginItem)
    }
}
