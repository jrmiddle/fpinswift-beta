func addOptionals (maybeX : Int?, maybeY : Int?) -> Int? {
    maybeX >>= {x in
    maybeY >>= {y in
    x + y}}
  }

func populationOfCapital (country : String) -> Int? {
    capitals[country] >>= {capital in
    cities[capital] >>= {population in
    return population * 1000}}
}