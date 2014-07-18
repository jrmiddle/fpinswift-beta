func genericComputeArray2<T> (xs : [Int], f : Int -> T) -> [T] {
       return map(xs,f)
}