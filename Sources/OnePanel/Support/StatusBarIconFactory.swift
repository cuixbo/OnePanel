import AppKit

enum StatusBarIconFactory {
    static func makeTemplateImage() -> NSImage {
        let image = NSImage(named: "StatusBarFromAppIcon") ?? NSImage()
        image.isTemplate = true
        return image
    }
}
