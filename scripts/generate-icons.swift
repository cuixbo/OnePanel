#!/usr/bin/env swift

import AppKit
import Foundation

let fileManager = FileManager.default
let root = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let resourcesURL = root.appending(path: "Resources")
let assetsCatalogURL = resourcesURL.appending(path: "Assets.xcassets")
let appIconSetURL = assetsCatalogURL.appending(path: "AppIcon.appiconset")
let iconsetURL = resourcesURL.appending(path: "AppIcon.iconset")
let icnsURL = resourcesURL.appending(path: "AppIcon.icns")
let sourceImageURL = resourcesURL
    .appending(path: "SourceArt")
    .appending(path: "onepanel-master-icon.png")

let entries: [(size: Int, filename: String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

guard let sourceImage = NSImage(contentsOf: sourceImageURL) else {
    throw NSError(
        domain: "OnePanelIconGeneration",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Missing source icon at \(sourceImageURL.path())"]
    )
}

try fileManager.createDirectory(at: appIconSetURL, withIntermediateDirectories: true)
try fileManager.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

for entry in entries {
    let resizedImage = try resizedImage(from: sourceImage, sideLength: entry.size)
    let data = try pngData(from: resizedImage)
    try data.write(to: appIconSetURL.appending(path: entry.filename))
    try data.write(to: iconsetURL.appending(path: entry.filename))
}

let contentsJSON = """
{
  "images" : [
    { "idiom" : "mac", "scale" : "1x", "size" : "16x16", "filename" : "icon_16x16.png" },
    { "idiom" : "mac", "scale" : "2x", "size" : "16x16", "filename" : "icon_16x16@2x.png" },
    { "idiom" : "mac", "scale" : "1x", "size" : "32x32", "filename" : "icon_32x32.png" },
    { "idiom" : "mac", "scale" : "2x", "size" : "32x32", "filename" : "icon_32x32@2x.png" },
    { "idiom" : "mac", "scale" : "1x", "size" : "128x128", "filename" : "icon_128x128.png" },
    { "idiom" : "mac", "scale" : "2x", "size" : "128x128", "filename" : "icon_128x128@2x.png" },
    { "idiom" : "mac", "scale" : "1x", "size" : "256x256", "filename" : "icon_256x256.png" },
    { "idiom" : "mac", "scale" : "2x", "size" : "256x256", "filename" : "icon_256x256@2x.png" },
    { "idiom" : "mac", "scale" : "1x", "size" : "512x512", "filename" : "icon_512x512.png" },
    { "idiom" : "mac", "scale" : "2x", "size" : "512x512", "filename" : "icon_512x512@2x.png" }
  ],
  "info" : {
    "author" : "codex",
    "version" : 1
  }
}
"""

let assetsCatalogContentsJSON = """
{
  "info" : {
    "author" : "codex",
    "version" : 1
  }
}
"""

try contentsJSON.data(using: .utf8)?.write(to: appIconSetURL.appending(path: "Contents.json"))
try contentsJSON.data(using: .utf8)?.write(to: iconsetURL.appending(path: "Contents.json"))
try assetsCatalogContentsJSON.data(using: .utf8)?.write(to: assetsCatalogURL.appending(path: "Contents.json"))

let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
task.arguments = ["-c", "icns", iconsetURL.path(), "-o", icnsURL.path()]
try task.run()
task.waitUntilExit()

guard task.terminationStatus == 0 else {
    throw NSError(domain: "OnePanelIconGeneration", code: Int(task.terminationStatus))
}

print("Source icon: \(sourceImageURL.path())")
print("Generated app icon assets at \(appIconSetURL.path())")
print("Generated icns at \(icnsURL.path())")

func resizedImage(from sourceImage: NSImage, sideLength: Int) throws -> NSImage {
    let targetSize = NSSize(width: sideLength, height: sideLength)
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: sideLength,
        pixelsHigh: sideLength,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )

    guard let bitmap else {
        throw NSError(domain: "OnePanelIconGeneration", code: 2)
    }

    bitmap.size = targetSize

    NSGraphicsContext.saveGraphicsState()
    let context = NSGraphicsContext(bitmapImageRep: bitmap)
    NSGraphicsContext.current = context
    context?.cgContext.interpolationQuality = .high
    sourceImage.draw(
        in: NSRect(origin: .zero, size: targetSize),
        from: NSRect(origin: .zero, size: sourceImage.size),
        operation: .copy,
        fraction: 1.0
    )
    NSGraphicsContext.restoreGraphicsState()

    let outputImage = NSImage(size: targetSize)
    outputImage.addRepresentation(bitmap)
    return outputImage
}

func pngData(from image: NSImage) throws -> Data {
    guard
        let tiffData = image.tiffRepresentation,
        let representation = NSBitmapImageRep(data: tiffData),
        let pngData = representation.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "OnePanelIconGeneration", code: 3)
    }

    return pngData
}
