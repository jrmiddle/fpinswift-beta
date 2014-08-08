extension Diagram {
  func sizeWithWidth(targetWidth: CGFloat) -> CGSize {
    let height = targetWidth * (size.height/size.width)
      return CGSize(width: targetWidth, height: height)
  }
}