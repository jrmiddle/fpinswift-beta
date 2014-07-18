
// *********************************************
// This code generates example PDFs for the book
// *********************************************

// =<<example1>>
// =<<example2>>

func writepdf(name: String, diagram: Diagram) {
  let filename = Process.arguments[0].stringByAppendingPathComponent("artwork/generated").stringByAppendingPathComponent(name + ".pdf")
  let data = pdf(diagram, 300)
  data.writeToFile(filename, atomically: false)
}

writepdf("example1", example1)
writepdf("example2", example2)

// =<<example3>>

writepdf("example3", example3)

writepdf("example4", blueSquare ||| redSquare)
writepdf("example5", Diagram.Align(Vector2D(x: 0.5,y: 1), blueSquare) ||| redSquare)
