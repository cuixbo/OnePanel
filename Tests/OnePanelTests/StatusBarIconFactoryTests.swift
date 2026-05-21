import AppKit
import Testing
@testable import OnePanel

struct StatusBarIconFactoryTests {
    @Test
    func createsTemplateImageWithRequestedSize() {
        let image = StatusBarIconFactory.makeTemplateImage(sideLength: 18)

        #expect(image.isTemplate)
        #expect(image.size.width == 18)
        #expect(image.size.height == 18)
        #expect(image.tiffRepresentation != nil)
    }
}
