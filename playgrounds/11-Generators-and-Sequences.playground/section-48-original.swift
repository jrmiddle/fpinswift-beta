func removeAnElement<T>(var array: [T]) -> GeneratorOf<[T]> {
    var i = 0
    return GeneratorOf {
        if i < array.count {
            var result = array.self
            result.removeAtIndex(i)
            i++
            return result
        }
        return nil
    }
}