let reverseSequence = ReverseSequence(array:xs)
let reverseGenerator = reverseSequence.generate()
while let i = reverseGenerator.next() {
  print("Index \(i) is \(xs[i])")
}