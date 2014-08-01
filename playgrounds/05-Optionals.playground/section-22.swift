func populationOfCapital (country : String) -> Int? {
  if let capital = capitals[country] {
    if let population = cities[capital] {
      return population * 1000
    }
  }
}
