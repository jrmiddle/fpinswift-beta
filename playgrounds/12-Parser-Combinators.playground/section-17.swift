func satisfy<Token>(condition: Token -> Bool) -> Parser<Token, Token> {
    return Parser { x in
        if let (head, tail) = x.match {
            if condition(head) { 
                return one((head, tail)) 
            }
        }
        return none()
    }
}