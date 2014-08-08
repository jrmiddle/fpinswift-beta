func join<A>(s: SequenceOf<SequenceOf<A>>) -> SequenceOf<A> {
    return SequenceOf {JoinedGenerator(map(s.generate()) {g in g.generate()})}
}

func map<A,B>(s:SequenceOf<A>, f : A -> B) -> SequenceOf<B> {    return SequenceOf {map(s.generate(),f)}}
func flatmap<A,B>(xs: SequenceOf<A>, f: A -> SequenceOf<B>) -> SequenceOf<B> {
    return join(map(xs,f))
}
