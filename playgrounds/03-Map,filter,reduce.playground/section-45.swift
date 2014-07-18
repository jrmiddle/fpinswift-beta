func mapUsingReduce<T,U> (xs : [T], f : T -> U) -> [U] {
  return reduce (xs,[]) {result, x in result + [f(x)]}
}

func filterUsingReduce<T> (xs : [T], check : T -> Bool) -> [T]{
  return reduce(xs, []) {result, x in check(x) ? result + [x] : result}
}