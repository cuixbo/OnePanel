import AppKit

enum StatusBarIconFactory {
    static func makeTemplateImage(sideLength: CGFloat = 18) -> NSImage {
        let image = NSImage(size: NSSize(width: sideLength, height: sideLength))

        image.lockFocus()
        defer { image.unlockFocus() }

        guard let context = NSGraphicsContext.current?.cgContext else {
            image.isTemplate = true
            return image
        }

        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
        context.interpolationQuality = .high

        let strokeColor = NSColor.black
        let ringLineWidth = sideLength * 0.095
        let glyphLineWidth = sideLength * 0.13
        let ringCenter = CGPoint(x: sideLength * 0.50, y: sideLength * 0.52)
        let ringRadius = sideLength * 0.33

        let accentArc = NSBezierPath()
        accentArc.lineWidth = ringLineWidth
        accentArc.lineCapStyle = .round
        accentArc.appendArc(
            withCenter: ringCenter,
            radius: ringRadius,
            startAngle: 96,
            endAngle: 120,
            clockwise: false
        )
        strokeColor.setStroke()
        accentArc.stroke()

        let mainArc = NSBezierPath()
        mainArc.lineWidth = ringLineWidth
        mainArc.lineCapStyle = .round
        mainArc.appendArc(
            withCenter: ringCenter,
            radius: ringRadius,
            startAngle: 136,
            endAngle: 28,
            clockwise: true
        )
        strokeColor.setStroke()
        mainArc.stroke()

        let dotRadius = sideLength * 0.050
        let dotCenter = point(
            center: ringCenter,
            radius: ringRadius * 1.02,
            degrees: 42
        )
        let dotRect = CGRect(
            x: dotCenter.x - dotRadius,
            y: dotCenter.y - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2
        )
        let dotPath = NSBezierPath(ovalIn: dotRect)
        strokeColor.setFill()
        dotPath.fill()

        let onePath = NSBezierPath()
        onePath.lineWidth = glyphLineWidth
        onePath.lineCapStyle = .round
        onePath.lineJoinStyle = .round
        onePath.move(to: CGPoint(x: sideLength * 0.42, y: sideLength * 0.26))
        onePath.line(to: CGPoint(x: sideLength * 0.36, y: sideLength * 0.33))
        onePath.move(to: CGPoint(x: sideLength * 0.42, y: sideLength * 0.26))
        onePath.line(to: CGPoint(x: sideLength * 0.42, y: sideLength * 0.67))
        strokeColor.setStroke()
        onePath.stroke()

        let pPath = NSBezierPath()
        pPath.lineWidth = glyphLineWidth
        pPath.lineCapStyle = .round
        pPath.lineJoinStyle = .round
        pPath.move(to: CGPoint(x: sideLength * 0.54, y: sideLength * 0.33))
        pPath.line(to: CGPoint(x: sideLength * 0.61, y: sideLength * 0.33))
        pPath.appendArc(
            withCenter: CGPoint(x: sideLength * 0.61, y: sideLength * 0.44),
            radius: sideLength * 0.12,
            startAngle: 90,
            endAngle: -90,
            clockwise: true
        )
        strokeColor.setStroke()
        pPath.stroke()

        image.isTemplate = true
        return image
    }

    private static func point(center: CGPoint, radius: CGFloat, degrees: CGFloat) -> CGPoint {
        let radians = degrees * .pi / 180
        return CGPoint(
            x: center.x + cos(radians) * radius,
            y: center.y + sin(radians) * radius
        )
    }
}
