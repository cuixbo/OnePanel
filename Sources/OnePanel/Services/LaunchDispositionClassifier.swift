import AppKit
import CoreServices
import Foundation

enum LaunchDisposition: Equatable {
    case manual
    case loginItem
}

struct LaunchDispositionClassifier {
    static func disposition(for openApplicationEvent: NSAppleEventDescriptor?) -> LaunchDisposition {
        guard
            let openApplicationEvent,
            openApplicationEvent.eventClass == AEEventClass(kCoreEventClass),
            openApplicationEvent.eventID == AEEventID(kAEOpenApplication)
        else {
            return .manual
        }

        let launchedAsLoginItem = openApplicationEvent
            .paramDescriptor(forKeyword: AEKeyword(keyAELaunchedAsLogInItem))?
            .booleanValue ?? false

        return launchedAsLoginItem ? .loginItem : .manual
    }
}
