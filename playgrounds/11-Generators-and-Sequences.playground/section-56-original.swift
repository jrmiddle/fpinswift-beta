func sum(xs : [Int]) -> Int {
    if let (head,tail) = xs.match
    {
        return (head + sum(tail))
    } else {
        return 0
    }
}