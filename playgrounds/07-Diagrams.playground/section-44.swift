    case .Attributed(.FillColor(let color), let d):
        CGContextSaveGState(context)
        color.set()
        draw(context, bounds, d.diagram())
        CGContextRestoreGState(context)
