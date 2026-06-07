import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

func icon(size: Int) -> NSBitmapImageRep {
    let s = CGFloat(size)
    let k = s / 1024
    guard let bitmap = NSBitmapImageRep(
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
    ) else {
        fatalError("Failed to create icon bitmap")
    }
    bitmap.size = NSSize(width: s, height: s)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.setShouldAntialias(true)
    ctx.setAllowsAntialiasing(true)

    NSColor(red: 0.90, green: 0.64, blue: 0.34, alpha: 1).setFill()
    ctx.fill(CGRect(x: 0, y: 0, width: s, height: s))

    let clip = NSBezierPath(
        roundedRect: NSRect(x: 0, y: 0, width: s, height: s),
        xRadius: 112 * k,
        yRadius: 112 * k
    )
    clip.addClip()

    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            NSColor(red: 0.98, green: 0.77, blue: 0.50, alpha: 1).cgColor,
            NSColor(red: 0.90, green: 0.60, blue: 0.31, alpha: 1).cgColor,
            NSColor(red: 0.97, green: 0.74, blue: 0.45, alpha: 1).cgColor,
        ] as CFArray,
        locations: [0, 0.62, 1]
    )!
    ctx.drawLinearGradient(
        gradient,
        start: CGPoint(x: 180 * k, y: 930 * k),
        end: CGPoint(x: 850 * k, y: 70 * k),
        options: []
    )

    ctx.setFillColor(NSColor.white.withAlphaComponent(0.10).cgColor)
    ctx.fillEllipse(in: CGRect(x: 105 * k, y: 430 * k, width: 810 * k, height: 520 * k))

    let brown = NSColor(red: 0.43, green: 0.16, blue: 0.035, alpha: 1)
    ctx.setStrokeColor(brown.cgColor)
    ctx.setFillColor(brown.cgColor)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setLineWidth(46 * k)
    ctx.beginPath()
    ctx.move(to: CGPoint(x: 140 * k, y: 515 * k))
    ctx.addLine(to: CGPoint(x: 506 * k, y: 755 * k))
    ctx.addLine(to: CGPoint(x: 884 * k, y: 515 * k))
    ctx.strokePath()

    NSBezierPath(
        roundedRect: NSRect(x: 690 * k, y: 595 * k, width: 94 * k, height: 150 * k),
        xRadius: 18 * k,
        yRadius: 18 * k
    ).fill()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let font = NSFont(name: "PingFangSC-Semibold", size: 242 * k)
        ?? NSFont(name: "Songti SC Bold", size: 242 * k)
        ?? NSFont.boldSystemFont(ofSize: 242 * k)
    NSString(string: "乡驿家").draw(
        in: NSRect(x: 86 * k, y: 252 * k, width: 852 * k, height: 260 * k),
        withAttributes: [
            .font: font,
            .foregroundColor: brown,
            .paragraphStyle: paragraph,
            .kern: -12 * k,
        ]
    )

    NSGraphicsContext.restoreGraphicsState()
    return bitmap
}

func write(_ path: String, _ size: Int) throws {
    let url = root.appendingPathComponent(path)
    try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    guard let png = icon(size: size).representation(using: .png, properties: [:]) else {
        fatalError("Failed to encode icon")
    }
    try png.write(to: url)
}

let targets: [(String, Int)] = [
    ("assets/app_icon/xyj_app_icon.png", 1024),
    ("android/app/src/main/res/mipmap-mdpi/ic_launcher.png", 48),
    ("android/app/src/main/res/mipmap-hdpi/ic_launcher.png", 72),
    ("android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", 96),
    ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", 144),
    ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", 192),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png", 20),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png", 40),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png", 60),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png", 29),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png", 58),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png", 87),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png", 40),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png", 80),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png", 120),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png", 120),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png", 180),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png", 76),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png", 152),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png", 167),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png", 1024),
    ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png", 16),
    ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png", 32),
    ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png", 64),
    ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png", 128),
    ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png", 256),
    ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png", 512),
    ("macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png", 1024),
    ("web/favicon.png", 32),
    ("web/icons/Icon-192.png", 192),
    ("web/icons/Icon-maskable-192.png", 192),
    ("web/icons/Icon-512.png", 512),
    ("web/icons/Icon-maskable-512.png", 512),
]

for target in targets {
    try write(target.0, target.1)
}

print("Generated \(targets.count) XYJ app icons.")
