func inRange₄(target: Position, ownPosition: Position, friendly: Position, range: Double) -> Bool {
   let dx = ownPosition.x - target.x
   let dy = ownPosition.y - target.y
   let friendlyDx = friendly.x - target.x
   let friendlyDy = friendly.y - target.y
   return sqrt(dx * dx + dy * dy) <= range
          && sqrt(dx * dx + dy * dy) >= minimumDistance
          && !(sqrt(friendlyDx * friendlyDx + friendlyDy * friendlyDy) >= minimumDistance)
}