func computeIntArray (xs : [Int], f : Int -> Int) -> [Int] {
    var result : [Int] = []
    for x in xs
    {
        result.append(f(x))
    }
    return result
}