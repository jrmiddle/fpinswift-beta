
import Foundation

struct Parser<Token, Result> {
    let p: Slice<Token> -> SequenceOf<(Result, Slice<Token>)>
}

infix operator <*  { associativity left precedence 150 }
infix operator  *> { associativity left precedence 150 }
infix operator </> { precedence 170 }

func none<A>() -> SequenceOf<A> {
    return SequenceOf(GeneratorOf { nil } )
}
func one<A>(x: A) -> SequenceOf<A> {
    return SequenceOf(GeneratorOfOne(x))
}

struct JoinedGenerator<A> : GeneratorType {
    typealias Element = A
    
    var generator: GeneratorOf<GeneratorOf<A>>
    var current: GeneratorOf<A>?
    
    init(_ g: GeneratorOf<GeneratorOf<A>>) {
        generator = g
        current = generator.next()
    }
    
    mutating func next() -> A? {
        if var c = current {
            if let x = c.next() {
                return x
            } else {
                current = generator.next()
                return next()
            }
        }
        return nil
    }
}

func flatMap<A,B>(ls: SequenceOf<A>, f: A -> SequenceOf<B>) -> SequenceOf<B> {
    return join(map(ls,f))
}

infix operator <*> { associativity left precedence 150 }
func <*><Token, A, B>(l: Parser<Token, A -> B>,
                      r: Parser<Token, A>) -> Parser<Token, B> {
    return Parser { input in                                          
        let leftResults = l.p(input)
        return flatMap(leftResults) { f, leftRemainder in
            let rightResults = r.p(leftRemainder)
            return map(rightResults) { x, y in (f(x), y) }
        }
    }
}

func pure<Token, A>(value: A) -> Parser<Token, A> {
    return Parser { one((value, $0)) }
}

func </> <Token, A, B>(l: A -> B, r: Parser<Token, A>) -> Parser<Token, B> {
    return pure(l) <*> r
}

func <* <Token, A, B>(p: Parser<Token, A>, q: Parser<Token, B>) -> Parser<Token, A> {
    return {x in {_ in x} } </> p <*> q
}
func *> <Token, A, B>(p: Parser<Token, A>, q: Parser<Token, B>) -> Parser<Token, B> {
    return {_ in {y in y} } </> p <*> q
}

func map<A,B>(var g: GeneratorOf<A>, f: A -> B) -> GeneratorOf<B> {
    return GeneratorOf { map(g.next(), f) }
}

func map<A,B>(var s: SequenceOf<A>, f: A -> B) -> SequenceOf<B> {
    return SequenceOf {  map(s.generate(), f) }
}

func join<A>(s: SequenceOf<SequenceOf<A>>) -> SequenceOf<A> {
    return SequenceOf { JoinedGenerator(map(s.generate()) { $0.generate() }) }
}

func +<A>(l: SequenceOf<A>, r: SequenceOf<A>) -> SequenceOf<A> {
    return join(SequenceOf([l,r]))
}

func const<A,B>(x: A) -> B -> A {
    return { _ in x }
}

func curry<A,B,C>(f: (A, B) -> C) -> A -> B -> C {
    return { x in { y in f(x, y) } }
}

func flip<A,B,C>(f: (B, A) -> C) -> (A, B) -> C {
    return { (x, y) in f(y, x) }
}

func prepend<A>(l: A) -> [A] -> [A] {
    return { (x: [A]) in [l] + x }
}

extension String {
    var characters: [Character] {
        var result: [Character] = []
        for c in self {
            result += [c]
        }
        return result
    }
    var slice: Slice<Character> {
        let res = self.characters
        return res[0..<res.count]
    }
}

func eof<A>() -> Parser<A, ()> {
    return Parser { stream in
        if (stream.isEmpty) {
            return one(((), stream))
        }
        return none()
    }
}


extension Slice {
    var head: T? {
        return self.isEmpty ? nil : self[0]
    }
    
    var tail: Slice<T> {
        return self.isEmpty ? self : self[(self.startIndex+1)..<self.endIndex]
    }
    
    var match: (head: T, tail: Slice<T>)? {
        return self.isEmpty ? nil : (self[self.startIndex], self.tail)
    }
}

func testParser<A>(parser: Parser<Character,A>, input: String) -> String {
    var result: [String] = []
    for (x, s) in parser.p(input.slice) {
        result += ["Success, found \(x), remainder: \(Array(s))"]
    }
    return result.isEmpty ? "Parsing failed." : join("\n", result)
}

func string(characters: [Character]) -> String {
    var s = ""
    s.extend(characters)
    return s
}

extension Character : Printable {
    public var description: String {
       return "\"" + self + "\""
    }
}

func member(set: NSCharacterSet, character: Character) -> Bool {
    let unichar = (String(character) as NSString).characterAtIndex(0)
    return set.characterIsMember(unichar)
}
