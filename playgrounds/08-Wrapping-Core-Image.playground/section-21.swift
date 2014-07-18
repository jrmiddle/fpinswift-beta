func composeFunctions <A, B, C>(func1: B -> C, func2: A -> B) -> (A -> C) {
    return {arg in func1(func2(arg)) }
}