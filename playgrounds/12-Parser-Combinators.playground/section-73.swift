let aOrB = symbol(a) <|> symbol(b)
func combine(a: Character)(b: Character)(c: Character) -> String {
  return a + b + c
}
let parser = pure(combine) <*> aOrB <*> aOrB <*> symbol(b)
testParser(parser, "abb")