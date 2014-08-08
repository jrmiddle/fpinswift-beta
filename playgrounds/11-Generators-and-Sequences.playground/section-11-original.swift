class PowerGenerator : GeneratorType {

    typealias Element = Int

    var power : Int = 1

    func next() -> Element? {
        let result = power
        power *= 2
        return result
    }
}