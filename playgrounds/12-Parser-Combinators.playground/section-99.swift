let plus: Character = "+"
func add(x: Int)(_: Character)(y: Int) -> Int {
  return x + y
}
let parseAddition = add </> number <*> symbol(plus) <*> number