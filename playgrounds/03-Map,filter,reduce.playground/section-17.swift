func map<T,U> (xs : [T], f : T -> U) -> [U] {
    var result : [U] = []
    for x in xs
    {
        result.append(f(x))
    }
    return result
}