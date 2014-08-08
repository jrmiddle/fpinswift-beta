func join<A>(s: SequenceOf<SequenceOf<A>>) -> SequenceOf<A> {
    return SequenceOf {JoinedGenerator(map(s.generate()) {g in g.generate()})}
}