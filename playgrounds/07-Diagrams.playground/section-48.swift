    case .Below(let top, let bottom):
        let t = top.diagram()
        let b = bottom.diagram()
        let (lFrame, rFrame) = splitVertical(bounds, b.size/diagram.size)
        draw(context, lFrame, b)
        draw(context, rFrame, t)