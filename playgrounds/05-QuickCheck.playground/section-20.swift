extension String : Arbitrary {
    static func arbitrary() -> String {
        let randomLength = random(from: 0, to: 100)
        var string = ""
        for _ in 0..<randomLength {
            let randomInt : Int = random(from: 13, to: 255)
            string += Character(UnicodeScalar(randomInt))
        }
        return string
    }
    
}
