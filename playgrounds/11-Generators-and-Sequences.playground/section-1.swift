import Foundation

func one<X>(x: X?) -> GeneratorOf<X> {
    return GeneratorOf(GeneratorOfOne(x))
}

func map<A,B>(var g: GeneratorOf<A>, f: A -> B) -> GeneratorOf<B> {
    return GeneratorOf {
        g.next().map(f)
    }
}

func map<A,B>(s:SequenceOf<A>, f : A -> B) -> SequenceOf<B> {
    return SequenceOf {map(s.generate(),f)}
}

protocol Smaller {
    func smaller() -> GeneratorOf<Self>
}

extension Int : Smaller {
    func smaller() -> GeneratorOf<Int> {
        let result : Int? = self < 0 ? nil : self.predecessor()
        return one(result)
    }
}
