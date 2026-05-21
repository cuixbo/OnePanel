import Foundation

@MainActor
struct StatusItemPanelPresenter {
    typealias Scheduler = (@escaping @MainActor () -> Void) -> Void

    private let scheduler: Scheduler

    init(scheduler: @escaping Scheduler = { action in
        DispatchQueue.main.async {
            action()
        }
    }) {
        self.scheduler = scheduler
    }

    func presentAfterStatusItemClick(_ action: @escaping @MainActor () -> Void) {
        scheduler(action)
    }
}
