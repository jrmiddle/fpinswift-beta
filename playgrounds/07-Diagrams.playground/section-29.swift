  case .Attributed(let attribute, let d):
    CGContextSaveGState(context)
    switch(attribute) {
      case .FillColor(let color):
        color.set()
    }
    draw(context,bounds,d.diagram())
    CGContextRestoreGState(context)
