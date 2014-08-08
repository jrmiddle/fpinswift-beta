func find <G : GeneratorType> (var generator : G, 
                               predicate : G.Element -> Bool) -> G.Element? {
                               
    while let x = generator.next() {
        if predicate(x) {
            return x
        }
    }
    return nil
}