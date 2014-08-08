func smaller<T : Smaller>(ls: [T]) -> GeneratorOf<[T]> {
  if let (head, tail) = ls.match {
        let gen1 : GeneratorOf<[T]> = one(tail)
        let gen2 : GeneratorOf<[T]> = map(smaller(tail), {xs in [head] + xs})
        let gen3 : GeneratorOf<[T]> = map(head.smaller(), {x in [x] + tail})
        return gen1 + gen2 + gen3
  } else {
    return one(nil)
  }
}