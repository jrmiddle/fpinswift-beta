func addOptionals (maybeX : Int?, maybeY : Int?) -> Int? {
  if let x = maybeX {
    if let y = maybeY {
        return x + y}
    }
  return nil
}
