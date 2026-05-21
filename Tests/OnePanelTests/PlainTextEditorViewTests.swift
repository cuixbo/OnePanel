import AppKit
import Foundation
import Testing
@testable import OnePanel

@MainActor
struct PlainTextEditorViewTests {
    @Test
    func appliesEditorAppearanceToTextView() {
        let textView = NSTextView()
        textView.string = "OnePanel"
        let appearance = EditorAppearance(
            fontFamilyName: "Helvetica",
            fontSize: 19,
            fontWeight: .bold,
            lineSpacing: 7,
            textColor: .custom(EditorColor(red: 0.25, green: 0.5, blue: 0.75, alpha: 1))
        )

        PlainTextEditorView.applyAppearance(appearance, to: textView)

        #expect(textView.font?.pointSize == 19)
        #expect(textView.font?.familyName == "Helvetica")
        #expect(isClose(textView.textColor?.usingColorSpace(.deviceRGB)?.redComponent, to: 0.25, tolerance: 0.08))
        #expect(isClose(textView.textColor?.usingColorSpace(.deviceRGB)?.greenComponent, to: 0.5, tolerance: 0.08))
        #expect(isClose(textView.textColor?.usingColorSpace(.deviceRGB)?.blueComponent, to: 0.75, tolerance: 0.08))
        #expect((textView.typingAttributes[.paragraphStyle] as? NSParagraphStyle)?.lineSpacing == 7)
    }

    private func isClose(_ value: CGFloat?, to expected: Double, tolerance: Double) -> Bool {
        guard let value else {
            return false
        }

        return abs(Double(value) - expected) <= tolerance
    }
}
