func checkHelper<A>(arbitraryInstance: ArbitraryI<A>, prop: A -> Bool, message: String) -> () {
    for _ in 0..numberOfIterations {
        let value = arbitraryInstance.arbitrary()
        if !prop(value) {
            let smallerValue = iterateWhile({ !prop($0) }, initialValue: value, arbitraryInstance.smaller)
            println("\"\(message)\" doesn't hold: \(smallerValue)")
            return
        }
    }
    println("\"\(message)\" passed \(numberOfIterations) tests.")
}