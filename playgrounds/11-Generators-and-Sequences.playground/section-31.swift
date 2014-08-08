struct ReverseSequence<T> : SequenceType {
    var array : [T]
    
    init (array : [T]) {
        self.array = array
    }
    
    typealias Generator = CountdownGenerator
    func generate() -> Generator {
        return CountdownGenerator(array:array)
    }
}