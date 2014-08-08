func insert(x : Int, xs : [Int]) -> [Int] {
    if let (head,tail) = xs.match
    {
        return (x <= head ? [x] + xs : [head] + insert(x,tail))
    } else {
        return [x]
    }
}