func rect(#width: Double, #height: Double) -> Diagram {
    return Diagram.Prim(Primitive.Rectangle(width, height))
}

func circle(#radius: Double) -> Diagram {
    return Diagram.Prim(Primitive.Ellipsis(radius, radius))
}

func text(#width: Double, #height: Double, text theText: String) -> Diagram {
    return Diagram.Prim(Primitive.Text(width, height, theText))
}