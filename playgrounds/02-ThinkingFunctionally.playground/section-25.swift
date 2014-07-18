func inRange(ownPosition: Position, target: Position, friendly: Position, range: Double) -> Bool {
  let targetRegion = shift(ownPosition, difference(circle(range), circle(minimumDistance)))
  let friendlyRegion = shift(friendly, circle(minimumDistance))
  return difference(targetRegion, friendlyRegion)(target)
}