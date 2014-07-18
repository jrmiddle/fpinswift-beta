func reduce<A,R>(arr : [A], initialValue: R, combine: (R,A) -> R) -> R {
    var result = initialValue
    for i in arr {
        result = combine(result,i)
    }
    return result
}