func check<X : Arbitrary>(message: String, prop : [X] -> Bool) -> () {
    let instance = ArbitraryI(arbitrary: arbitraryArray, 
                              smaller: { (x: [X]) in x.smaller() })
    checkHelper(instance, prop, message)
}