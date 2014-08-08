    case .Prim(let size, .Rectangle):
        let frame = fit(Vector2D(x: 0.5, y: 0.5), size, bounds)
        CGContextFillRect(context, frame)
