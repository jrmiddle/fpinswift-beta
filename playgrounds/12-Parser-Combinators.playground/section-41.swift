let p : Parser<Character, (Character, Character)> = sequence(symbol(x), symbol(y))
testParser(p, "xyz")