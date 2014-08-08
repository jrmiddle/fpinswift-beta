enum Diagram {
    case Prim(CGSize, Primitive)
    case Beside(DiagramLike, DiagramLike)
    case Below(DiagramLike, DiagramLike)
    case Attributed(Attribute, DiagramLike)
    case Align(Vector2D, DiagramLike)
}