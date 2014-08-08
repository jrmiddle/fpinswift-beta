func recurse<Token, A>(f: @autoclosure () -> Parser<Token, A>) -> Parser<Token, A> {
    return Parser { f().p($0) }
}