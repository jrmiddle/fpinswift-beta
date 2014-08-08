func countDown(start:Int) -> GeneratorOf<Int> {
    var i = start
    return GeneratorOf {return i < 0 ? nil : i--}
}