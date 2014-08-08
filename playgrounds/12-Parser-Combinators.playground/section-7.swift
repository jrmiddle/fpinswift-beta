func parseA() -> Parser<Character, Character> {
    let a : Character = "a"
    return Parser { x in
        if let (head, tail) = x.match {
            if head == a { 
                return one((a, tail)) 
            }
        }
        return none()
    }
}