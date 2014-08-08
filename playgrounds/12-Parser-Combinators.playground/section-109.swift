func operator0(character: Character, 
               evaluate: (Int, Int) -> Int, 
               next: Calculator) -> Calculator {
               
   return { x in { y in evaluate(x,y) } } </> next <* symbol(character) <*> next
}

func pAtom0() -> Calculator { return number }
func pMultiply0() -> Calculator { return operator0("*", *, pAtom0()) }
func pAdd0() -> Calculator { return operator0("+", +, pMultiply0()) }
func pExpression0() -> Calculator { return pAdd0() }

testParser(pExpression0(), "1+3*3")