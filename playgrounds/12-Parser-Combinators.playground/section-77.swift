let parser2 = pure(curry {$0 + $1 + $2}) <*> aOrB <*> aOrB <*> symbol(b)
testParser(parser2, "abb")