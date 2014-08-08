func many<Token,A>(p: Parser<Token,A>) -> Parser<Token,[A]> {
    return (pure(prepend) <*> p <*> recurse(many(p))) <|> pure([])
}