#!/usr/bin/env swift

import AppKit
import Foundation

let fileManager = FileManager.default
let projectRoot = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let resourcesURL = projectRoot.appendingPathComponent("Sources/RoomServiceApp/Resources", isDirectory: true)
let docsAssetsURL = projectRoot.appendingPathComponent("docs/assets", isDirectory: true)
let iconsetURL = resourcesURL.appendingPathComponent("AppIcon.iconset", isDirectory: true)
let iconURL = resourcesURL.appendingPathComponent("AppIcon.icns")
let marketingPNGURL = docsAssetsURL.appendingPathComponent("roomservice-marketing.png")

try fileManager.createDirectory(at: resourcesURL, withIntermediateDirectories: true)
try fileManager.createDirectory(at: docsAssetsURL, withIntermediateDirectories: true)
if fileManager.fileExists(atPath: iconsetURL.path) {
    try fileManager.removeItem(at: iconsetURL)
}
try fileManager.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

let masterSize: CGFloat = 1024
let image = NSImage(size: NSSize(width: masterSize, height: masterSize), flipped: false) { rect in
    let background = NSBezierPath(roundedRect: rect, xRadius: 220, yRadius: 220)
    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.08, green: 0.53, blue: 0.72, alpha: 1.0),
        NSColor(calibratedRed: 0.19, green: 0.74, blue: 0.68, alpha: 1.0),
    ])!
    gradient.draw(in: background, angle: -35)

    let innerRect = rect.insetBy(dx: 112, dy: 112)
    NSColor.white.withAlphaComponent(0.18).setFill()
    NSBezierPath(roundedRect: innerRect, xRadius: 146, yRadius: 146).fill()

    func capsule(_ frame: CGRect, alpha: CGFloat) {
        NSColor.white.withAlphaComponent(alpha).setFill()
        NSBezierPath(roundedRect: frame, xRadius: frame.height / 2, yRadius: frame.height / 2).fill()
    }

    capsule(CGRect(x: 356, y: 590, width: 312, height: 64), alpha: 0.94)
    capsule(CGRect(x: 320, y: 494, width: 384, height: 88), alpha: 0.94)
    capsule(CGRect(x: 272, y: 356, width: 480, height: 112), alpha: 0.90)

    let sparkleAttributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 178, weight: .bold),
        .foregroundColor: NSColor.white.withAlphaComponent(0.92),
    ]
    let sparkle = NSAttributedString(string: "✦", attributes: sparkleAttributes)
    sparkle.draw(at: CGPoint(x: 702, y: 688))

    return true
}

guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not render icon")
}

try pngData.write(to: marketingPNGURL)

let sizes = [16, 32, 64, 128, 256, 512, 1024]
for size in sizes {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!

    rep.size = NSSize(width: size, height: size)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high
    image.draw(in: CGRect(x: 0, y: 0, width: CGFloat(size), height: CGFloat(size)))
    NSGraphicsContext.restoreGraphicsState()

    if let data = rep.representation(using: .png, properties: [:]) {
        let name = "icon_\(size)x\(size).png"
        try data.write(to: iconsetURL.appendingPathComponent(name))
        if size <= 512 {
            let doubleName = "icon_\(size / 2)x\(size / 2)@2x.png"
            try data.write(to: iconsetURL.appendingPathComponent(doubleName))
        }
    }
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", iconURL.path]
try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    fatalError("iconutil failed with status \(process.terminationStatus)")
}

try? fileManager.removeItem(at: iconsetURL)

print("Generated \(iconURL.path)")
print("Generated \(marketingPNGURL.path)")
