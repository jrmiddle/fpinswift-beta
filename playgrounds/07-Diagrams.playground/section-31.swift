  case .Beside(let left, let right):
    let l = left.diagram()
    let r = right.diagram()
    let (lFrame, rFrame) = splitHorizontal(bounds, l.size/diagram.size)
    draw(context,lFrame,l)
    draw(context,rFrame,r)