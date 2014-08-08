func flatmap<A,B>(xs: SequenceOf<A>, f: A -> SequenceOf<B>) -> SequenceOf<B> {
    return join(map(xs,f))
}