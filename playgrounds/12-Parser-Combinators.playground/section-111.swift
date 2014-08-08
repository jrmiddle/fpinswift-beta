func operator1(character: Character, 
               evaluate: (Int, Int) -> Int, 
               next: Calculator) -> Calculator {
               
   let withOperator = { x in { y in evaluate(x,y) } } </> next <* symbol(character) <*> next
   return withOperator <|> next
}