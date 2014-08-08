func arbitraryArray<X: Arbitrary>() -> [X] {
  let randomLength = Int(arc4random() % 50)
  return repeat(randomLength) {_ in return X.arbitrary() }
}