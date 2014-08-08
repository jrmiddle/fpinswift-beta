class LimitGenerator<G : GeneratorType> : GeneratorType
{
    typealias Element = G.Element
    var limit = 0
    var generator : G

    init (limit : Int, generator : G) {
        self.limit = limit
        self.generator = generator
    }
    
    func next() -> Element? {
        if limit >= 0 {
            limit--
            generator.next()
        }
        else {
            return nil
        }
    }
}