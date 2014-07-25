extension Diagram {
  var size : CGSize {
    switch self {
      case .Prim(let size, _):
        return size
      case .Attributed(_, let x):
        return x.diagram().size
      case .Beside(let l, let r):
        let sizeL = l.diagram().size
        let sizeR = r.diagram().size
        return CGSizeMake(sizeL.width+sizeR.width,max(sizeL.height,sizeR.height))
      case .Below(let l, let r):
        let sizeL = l.diagram().size
        let sizeR = r.diagram().size
        return CGSizeMake(max(sizeL.width,sizeR.width),sizeL.height+sizeR.height)
      case .Align(_, let r):
        return r.diagram().size
    }
  }

}