func symbol<Token: Equatable>(symbol: Token) -> Parser<Token, Token> {
    return satisfy { $0 == symbol }
}