    case .Prim(let size, .Text(let text)):
        let frame = fit(Vector2D(x: 0.5, y: 0.5), size, bounds)
        let attributes = [NSFontAttributeName: NSFont.systemFontOfSize(12)]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        attributedText.drawInRect(frame)