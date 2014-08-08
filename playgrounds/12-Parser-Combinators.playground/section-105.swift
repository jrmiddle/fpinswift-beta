let multiply : Character = "*"
let parseMultiplication = curry(*) </> number <* symbol(multiply) <*> number
testParser(parseMultiplication, "8*8")