  case .Below(let bottom, let top):
    let b = bottom.diagram()
    let t = top.diagram()
    let (lFrame, rFrame) = splitVertical(bounds, b.size/diagram.size)
    draw(context,lFrame,b)
    draw(context,rFrame,t)