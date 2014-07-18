  case .Prim(Primitive.Text(let width, let height, let text)):
      let frame = fit(Vector2D(x: 0.5, y: 0.5), CGSizeMake(width, height), bounds)
      let attributes = [NSFontAttributeName: NSFont.systemFontOfSize(12)]
      let attributedText = NSAttributedString(string: text, attributes: attributes)
      attributedText.drawInRect(frame)