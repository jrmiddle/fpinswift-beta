  case .Align(let vec, let d):
    let diagram = d.diagram()
    let frame = fit(vec, diagram.size, bounds)
    draw(context,frame,diagram)
  }
}