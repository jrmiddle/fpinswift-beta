operator infix >>= {}

@infix func >>= <U,T> (maybeX : T?, f : T -> U?) -> U? {
    if let x = maybeX
    {
        return f(x)
    }
    else
    {
        return nil
    }
}