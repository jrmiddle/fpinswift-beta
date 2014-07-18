typealias Position = CGPoint

func inRange1(target: Position, range: Double) -> Bool {
   return sqrt(target.x * target.x + target.y * target.y) <= range
}