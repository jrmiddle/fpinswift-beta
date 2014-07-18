func computeBoolArray (xs : Int[], f : Int -> Bool) -> Bool [] {
    let result = Array(count:xs.count, repeatedValue: 0)
    for i in 0 .. xs.count
    {
        result[i] = f(xs[i])
    }
    return result
}