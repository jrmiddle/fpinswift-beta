struct ArbitraryI<T> {
    let arbitrary : () -> T
    let smaller: T -> T?
}
