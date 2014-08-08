let reverseElements = map(ReverseSequence(array:xs)){i in xs[i]}
for x in reverseElements {
  print("Element is \(x)")
}