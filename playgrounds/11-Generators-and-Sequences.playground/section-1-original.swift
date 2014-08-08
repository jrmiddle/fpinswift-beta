

func map<T,U>(var g : GeneratorOf<T>, f : T -> U) -> GeneratorOf<U> {
    return (GeneratorOf {
        if let x = g.next() {
            return f(x)
        }
        else {
            return nil
        }})
}

func one<X>(x: X?) -> GeneratorOf<X> {
    return GeneratorOf(GeneratorOfOne(x))
}


func map<A,B>(var g: GeneratorOf<A>, f: A -> B) -> GeneratorOf<B> {
    return GeneratorOf {
        g.next().map(f)
    }
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
