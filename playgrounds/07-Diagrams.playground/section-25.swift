  case .Prim(Primitive.Rectangle(let width, let height)):
      let frame = fit(Vector2D(x: 0.5, y: 0.5), CGSizeMake(width, height), bounds)
      CGContextFillRect(context, frame)
