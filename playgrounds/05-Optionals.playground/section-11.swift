func map<T,U> (maybeX : T?, f : T -> U) -> U? {
  if let x = maybeX {
    return f(x)
  }
  else {
    return nil
  }
}