func product(xs : [Int]) -> Int {
    var result : Int = 1
    for x in xs {
        result = x * result
    }
    return result
}