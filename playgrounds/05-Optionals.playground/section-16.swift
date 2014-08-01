func incrementOptional2 (maybeX : Int?) -> Int? {
    return maybeX.map{x in x + 1}
}
