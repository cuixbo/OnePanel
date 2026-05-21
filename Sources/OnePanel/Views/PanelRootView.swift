import SwiftUI

struct PanelRootView: View {
    @ObservedObject var model: AppModel
    let onExit: () -> Void

    var body: some View {
        PlainTextEditorView(model: model)
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
        )
        .padding(8)
        .onExitCommand(perform: onExit)
    }
}
