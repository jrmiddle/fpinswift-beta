extension Diagram {
    func fill(color: NSColor) -> Diagram {
      return Diagram.Attributed(Attribute.FillColor(color), self)
    }
    
    func alignTop() -> Diagram {
        return Diagram.Align(Vector2D(x: 0.5,y: 1), self)
    }
    
    func alignBottom() -> Diagram {
        return Diagram.Align(Vector2D(x:0.5, y: 0), self)
    }
    
}