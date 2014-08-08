protocol DiagramLike { func diagram() -> Diagram }

extension Diagram: DiagramLike {
  func diagram() -> Diagram { return self }
}