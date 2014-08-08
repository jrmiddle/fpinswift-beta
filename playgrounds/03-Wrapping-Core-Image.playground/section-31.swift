func add2(x : Int) -> (Int -> Int) {
  return {y in return x + y}
}