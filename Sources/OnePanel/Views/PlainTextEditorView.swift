import AppKit
import SwiftUI

struct PlainTextEditorView: NSViewRepresentable {
    @ObservedObject var model: AppModel

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true

        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }

        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.allowsUndo = true
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.textContainerInset = NSSize(width: 4, height: 8)
        context.coordinator.isSynchronizingFromModel = true
        textView.string = model.documentText
        context.coordinator.isSynchronizingFromModel = false
        Self.applyAppearance(model.settings.editorAppearance, to: textView)
        textView.delegate = context.coordinator

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else {
            return
        }

        context.coordinator.model = model

        if textView.string != model.documentText {
            context.coordinator.isSynchronizingFromModel = true
            textView.string = model.documentText
            context.coordinator.isSynchronizingFromModel = false
        }

        Self.applyAppearance(model.settings.editorAppearance, to: textView)
    }

    @MainActor
    static func applyAppearance(_ appearance: EditorAppearance, to textView: NSTextView) {
        let font = appearance.resolvedFont()
        let textColor = appearance.textColor.nsColor
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(appearance.lineSpacing)

        textView.font = font
        textView.textColor = textColor
        textView.insertionPointColor = textColor
        textView.defaultParagraphStyle = paragraphStyle

        var typingAttributes = textView.typingAttributes
        typingAttributes[.font] = font
        typingAttributes[.foregroundColor] = textColor
        typingAttributes[.paragraphStyle] = paragraphStyle
        textView.typingAttributes = typingAttributes

        guard let textStorage = textView.textStorage else {
            return
        }

        let fullRange = NSRange(location: 0, length: textStorage.length)
        textStorage.beginEditing()
        if fullRange.length > 0 {
            textStorage.addAttributes(
                [
                    .font: font,
                    .foregroundColor: textColor,
                    .paragraphStyle: paragraphStyle
                ],
                range: fullRange
            )
        }
        textStorage.endEditing()
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        var model: AppModel
        var isSynchronizingFromModel = false

        init(model: AppModel) {
            self.model = model
        }

        func textDidChange(_ notification: Notification) {
            guard
                !isSynchronizingFromModel,
                let textView = notification.object as? NSTextView
            else {
                return
            }

            do {
                try model.updateDocumentText(textView.string)
            } catch {
                NSLog("OnePanel failed to save document: \(error.localizedDescription)")
            }
        }
    }
}
