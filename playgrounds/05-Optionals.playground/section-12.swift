func incrementOptional (maybeX : Int?) -> Int? {
  if let x = maybeX {
    return x + 1
  }
  else {
    return nil
  }
}
