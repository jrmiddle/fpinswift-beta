func sumUsingReduce (xs : [Int]) -> Int {
  return reduce(xs, 0) {result, x in x + result}
  }

func productUsingReduce (xs : [Int]) -> Int {
  return reduce(xs, 1) {result, x in x * result}
  }

func concatUsingReduce (xs : [String]) -> String {
  return reduce (xs, "") {result, x in x + result}
  }