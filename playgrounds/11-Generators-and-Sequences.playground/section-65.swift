func smaller1<T>(array: [T]) -> GeneratorOf<[T]> {
    if let (head,tail) = array.match {
        let gen1 : GeneratorOf<[T]> = one(tail)
        let gen2 : GeneratorOf<[T]> = map(smaller1(tail),{smallerTail in [head] + smallerTail})
        return gen1 + gen2
    } else {
        return one(nil)
    }
}
