func genericComputeArray<T> (xs : [Int], f : Int -> T) -> [T] {
    var result : [T] = []
    for x in xs
    {
        result.append(f(x))
    }
    return result
}