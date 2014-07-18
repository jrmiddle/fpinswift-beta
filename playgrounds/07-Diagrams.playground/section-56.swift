func rect(#width: Double, #height: Double) -> Diagram {
    return Diagram.Prim(CGSizeMake(width, height), .Rectangle)
}

func circle(#radius: Double) -> Diagram {
    return Diagram.Prim(CGSizeMake(radius, radius), .Ellipsis)
}

func text(#width: Double, #height: Double, text theText: String) -> Diagram {
    return Diagram.Prim(CGSizeMake(width, height), .Text(theText))
}

func square(#side: Double) -> Diagram { 
  return rect(width: side, height: side) 
}