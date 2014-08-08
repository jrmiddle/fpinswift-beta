func op(character: Character, 
        evaluate: (Int, Int) -> Int, 
        next: Calculator) -> Calculator {
        
    let withOperator = curry(flip(evaluate)) </ symbol(character) <*> next
    return optionallyFollowed(next, withOperator)
}