func inRange(ownPosition: Position, target: Position, 
             friendly: Position, range: Distance) -> Bool {
  let targetRegion = shift(ownPosition, difference(circle(range), 
                                        circle(minimumDistance)))
  let friendlyRegion = shift(friendly, circle(minimumDistance))
  let resultRegion = difference(targetRegion, friendlyRegion)
  return resultRegion(target)
}