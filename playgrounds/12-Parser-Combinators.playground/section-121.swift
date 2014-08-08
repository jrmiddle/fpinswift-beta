func optionallyFollowed<A>(l: Parser<Character, A>, 
                           r: Parser<Character, A -> A>) -> Parser<Character, A> {
                           
  let apply: A -> (A -> A) -> A = { x in { f in f(x) } }
  return apply </> l <*> (r <|> pure { $0 })
}