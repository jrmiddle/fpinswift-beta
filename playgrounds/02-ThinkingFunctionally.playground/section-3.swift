typealias Position = CGPoint
typealias Distance = CGFloat

func inRange1(target: Position, range: Distance) -> Bool {
   return sqrt(target.x * target.x + target.y * target.y) <= range
}