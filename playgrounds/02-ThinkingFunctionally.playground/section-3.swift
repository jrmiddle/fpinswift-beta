typealias Position = CGPoint

func inRange₁(target: Position, range: Double) -> Bool {
   return sqrt(target.x * target.x + target.y * target.y) <= range
}