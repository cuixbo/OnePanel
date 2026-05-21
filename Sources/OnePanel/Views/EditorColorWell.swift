import AppKit
import SwiftUI

struct EditorColorWell: NSViewRepresentable {
    @Binding var color: NSColor

    func makeCoordinator() -> Coordinator {
        Coordinator(color: $color)
    }

    func makeNSView(context: Context) -> NSColorWell {
        let colorWell = NSColorWell()
        colorWell.color = color
        colorWell.target = context.coordinator
        colorWell.action = #selector(Coordinator.colorDidChange(_:))
        return colorWell
    }

    func updateNSView(_ nsView: NSColorWell, context: Context) {
        if !nsView.color.isEqual(color) {
            nsView.color = color
        }
    }

    @MainActor
    final class Coordinator: NSObject {
        private var color: Binding<NSColor>

        init(color: Binding<NSColor>) {
            self.color = color
        }

        @objc
        func colorDidChange(_ sender: NSColorWell) {
            color.wrappedValue = sender.color
        }
    }
}
