let xs = ["A","B","C"]
let generator = CountdownGenerator(array:xs)
while let i = generator.next() {
    println("Element \(i) of the array is \(xs[i])")
}