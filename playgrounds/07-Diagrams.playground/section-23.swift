func draw(context: CGContextRef, bounds: CGRect, diagram: Diagram) {
  switch diagram {
     case .Prim(Primitive.Ellipsis(let width, let height)):
      let frame = fit(Vector2D(x: 0.5, y: 0.5), CGSizeMake(width, height), bounds)
      CGContextFillEllipseInRect(context, frame)