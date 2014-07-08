extension Int : Arbitrary {
    static func arbitrary() -> Int {
        return Int(arc4random())
    }
} 