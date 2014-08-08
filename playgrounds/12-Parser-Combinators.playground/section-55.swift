func combinator<Token, A, B>(l: Parser<Token, A -> B>,
                             r: Parser<Token, A>) -> Parser<Token, B> {
                                 
    return Parser { input in                                          
        let leftResults = l.p(input)
        return flatMap(leftResults) { f, leftRemainder in
            let rightResults = r.p(leftRemainder)
            return map(rightResults) { x, rightRemainder in (f(x), rightRemainder) }
        }
    }
}