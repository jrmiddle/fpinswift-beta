let p2 = sequence(sequence(symbol(x), symbol(y)), symbol(z))
testParser(p2, "xyz")