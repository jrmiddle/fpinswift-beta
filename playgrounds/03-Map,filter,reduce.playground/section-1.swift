func incrementArray (xs : Int[]) -> Int[] {
    let result = Array(count:xs.count, repeatedValue: 0)
    for i in 0 .. xs.count
    {
        result[i] = xs[i] + 1
    }
    return result
}