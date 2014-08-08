func findPower(predicate : Int -> Bool) -> Int {
    let g = PowerGenerator()
    while let x = g.next() {
        if predicate(x) {
            return x
        }
    }
    return 0;
}