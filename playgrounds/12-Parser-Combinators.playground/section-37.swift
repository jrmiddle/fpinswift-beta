func sequence<Token, A, B>(l: Parser<Token, A>, 
                           r: Parser<Token, B>) -> Parser<Token, (A,B)> {
                           
    return Parser { input in 
        let leftResults = l.p(input)
        return flatMap(leftResults) { a, leftRest in 
            let rightResults = r.p(leftRest)
            return map(rightResults, { b, rightRest in
                ((a, b), rightRest)
            })    
        }
    }
}