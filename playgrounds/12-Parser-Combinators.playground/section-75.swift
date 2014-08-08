func curry<A,B,C,D>(f: (A, B, C) -> D) -> A -> B -> C -> D {
  return { a in { b in { c in f(a,b,c) } } }
}