import AppKit

func color(_ hex: UInt32) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255, alpha: 1)
}

struct Palette {
    let bgTop: NSColor, bgBottom: NSColor
    let cardBack: NSColor, cardFront: NSColor, cardBorder: NSColor
    let ink: NSColor, accent: NSColor, star: NSColor
}

func serifFont(size: CGFloat) -> NSFont {
    NSFont(name: "IowanOldStyle-Bold", size: size)
        ?? NSFont(name: "Georgia-Bold", size: size)
        ?? NSFont.systemFont(ofSize: size, weight: .bold)
}

func drawStar(center: CGPoint, radius: CGFloat, color: NSColor) {
    let path = NSBezierPath()
    for i in 0..<10 {
        let angle = CGFloat(i) * .pi / 5 - .pi / 2
        let r = i % 2 == 0 ? radius : radius * 0.4
        let p = CGPoint(x: center.x + r * cos(angle), y: center.y - r * sin(angle))
        if i == 0 { path.move(to: p) } else { path.line(to: p) }
    }
    path.close()
    color.setFill()
    path.fill()
}

func makeIcon(_ p: Palette, gradient: Bool, out: String) {
    let S: CGFloat = 1024
    let img = NSImage(size: NSSize(width: S, height: S))
    img.lockFocus()

    // background
    if gradient {
        NSGradient(starting: p.bgBottom, ending: p.bgTop)?
            .draw(in: NSRect(x: 0, y: 0, width: S, height: S), angle: 90)
    } else {
        p.bgBottom.setFill()
        NSRect(x: 0, y: 0, width: S, height: S).fill()
    }

    func card(w: CGFloat, h: CGFloat, rot: CGFloat, fill: NSColor, border: NSColor?, shadow: Bool, content: (() -> Void)? = nil) {
        NSGraphicsContext.current?.saveGraphicsState()
        let t = NSAffineTransform()
        t.translateX(by: S / 2, yBy: S / 2)
        t.rotate(byDegrees: rot)
        t.concat()
        let rect = NSRect(x: -w / 2, y: -h / 2, width: w, height: h)
        let path = NSBezierPath(roundedRect: rect, xRadius: 56, yRadius: 56)
        if shadow {
            let sh = NSShadow()
            sh.shadowColor = NSColor.black.withAlphaComponent(0.30)
            sh.shadowOffset = NSSize(width: 0, height: -14)
            sh.shadowBlurRadius = 40
            sh.set()
        }
        fill.setFill()
        path.fill()
        NSShadow().set()
        if let border {
            border.setStroke()
            path.lineWidth = 6
            path.stroke()
        }
        content?()
        NSGraphicsContext.current?.restoreGraphicsState()
    }

    // back card peeking out
    card(w: 660, h: 850, rot: -7, fill: p.cardBack, border: nil, shadow: true)

    // front card with content (content draws in rotated space, centered at 0,0)
    card(w: 660, h: 850, rot: 3, fill: p.cardFront, border: p.cardBorder, shadow: true) {
        drawStar(center: CGPoint(x: 0, y: 250), radius: 74, color: p.star)

        let numFont = serifFont(size: 360)
        let numAttrs: [NSAttributedString.Key: Any] = [.font: numFont, .foregroundColor: p.ink]
        let num = NSAttributedString(string: "128", attributes: numAttrs)
        let ns = num.size()
        num.draw(at: NSPoint(x: -ns.width / 2, y: -ns.height / 2 - 30))

        let capFont = NSFont.systemFont(ofSize: 64, weight: .semibold)
        let capAttrs: [NSAttributedString.Key: Any] = [.font: capFont, .foregroundColor: p.accent, .kern: 22]
        let cap = NSAttributedString(string: "CIVICS", attributes: capAttrs)
        let cs = cap.size()
        cap.draw(at: NSPoint(x: -cs.width / 2 + 11, y: -310))
    }

    img.unlockFocus()

    guard let tiff = img.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        fatalError("encode failed")
    }
    // force exact 1024 pixel size
    rep.size = NSSize(width: 1024, height: 1024)
    try! png.write(to: URL(fileURLWithPath: out))
    print("wrote", out)
}

let light = Palette(
    bgTop: color(0x35547f), bgBottom: color(0x243a5c),
    cardBack: color(0xe9e6da), cardFront: color(0xfdfdfb), cardBorder: color(0xd8dad2),
    ink: color(0x1d2433), accent: color(0x2e4a76), star: color(0x9e3f38))

let dark = Palette(
    bgTop: color(0x1c2230), bgBottom: color(0x101420),
    cardBack: color(0x232b3d), cardFront: color(0x2a3348), cardBorder: color(0x3d4763),
    ink: color(0xe7e8e3), accent: color(0x7d9cc9), star: color(0xd98a83))

let tinted = Palette(
    bgTop: .black, bgBottom: .black,
    cardBack: color(0x3a3a3a), cardFront: color(0x5a5a5a), cardBorder: color(0x777777),
    ink: .white, accent: color(0xcccccc), star: color(0xbbbbbb))

makeIcon(light, gradient: true, out: "/tmp/appicon/AppIcon.png")
makeIcon(dark, gradient: true, out: "/tmp/appicon/AppIcon-Dark.png")
makeIcon(tinted, gradient: false, out: "/tmp/appicon/AppIcon-Tinted.png")
