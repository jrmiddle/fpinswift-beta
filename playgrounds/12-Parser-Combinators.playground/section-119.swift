infix operator </  { precedence 170 }
func </ <Token,A,B>(l: A, r: Parser<Token,B>) -> Parser<Token,A> {
    return pure(l) <* r
}