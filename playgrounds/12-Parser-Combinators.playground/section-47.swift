func sequence3<Token, A, B, C>(p1: Parser<Token, A>, 
                               p2: Parser<Token, B>, 
                               p3: Parser<Token, C>) -> Parser<Token, (A, B, C)> {
                               
    return Parser { input in
        let p1Results = p1.p(input)
        return flatMap(p1Results) { a, p1Rest in
            let p2Results = p2.p(p1Rest)
            return flatMap(p2Results) {b, p2Rest in
                let p3Results = p3.p(p2Rest)
                return map(p3Results, { c, p3Rest in
                    ((a, b, c), p3Rest)
                })
            }
        }
    }
}

let p3 = sequence3(symbol(x), symbol(y), symbol(z))
testParser(p3, "xyz")