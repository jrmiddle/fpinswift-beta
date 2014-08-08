func rect(#width: CGFloat, #height: CGFloat) -> Diagram {
    return Diagram.Prim(CGSizeMake(width, height), .Rectangle)
}

func circle(#radius: CGFloat) -> Diagram {
    return Diagram.Prim(CGSizeMake(radius, radius), .Ellipsis)
}

func text(#width: CGFloat, #height: CGFloat, text theText: String) -> Diagram {
    return Diagram.Prim(CGSizeMake(width, height), .Text(theText))
}

func square(#side: CGFloat) -> Diagram { 
  return rect(width: side, height: side) 
}