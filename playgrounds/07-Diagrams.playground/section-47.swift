operator infix ||| { associativity left }
@infix func ||| (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Beside(l, r)
}

operator infix --- { associativity left }
@infix func --- (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Below(l, r)
}