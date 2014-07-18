func filter<T> (xs : [T], check : T -> Bool) -> [T] {
    var result : [T] = []
    for x in xs {
        if check(x) {
            result.append(x)
        }
    }
    return result
}