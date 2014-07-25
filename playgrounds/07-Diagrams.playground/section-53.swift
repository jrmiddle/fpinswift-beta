
// *********************************************
// This code generates example PDFs for the book
// *********************************************

let blueSquare = square(side: 1).fill(NSColor.blueColor())
let redSquare = square(side: 2).fill(NSColor.redColor())
let greenCircle = circle(radius: 1).fill(NSColor.greenColor())
let example1 = blueSquare ||| redSquare ||| greenCircle
let example2 = blueSquare ||| circle(radius: 1).fill(NSColor.cyanColor()) ||| redSquare ||| greenCircle

func writepdf(name: String, diagram: Diagram) {
  let filename = Process.arguments[2].stringByAppendingPathComponent("artwork/generated").stringByAppendingPathComponent(name + ".pdf")
  let data = pdf(diagram, 300)
  data.writeToFile(filename, atomically: false)
}

writepdf("example1", example1)
writepdf("example2", example2)

func barGraph(input: [(String,Double)]) -> Diagram {
    let values : [CGFloat] = input.map { CGFloat($0.1) }
    let bars =  hcat(normalize(values).map { (x: CGFloat) -> Diagram in
        return rect(width: 1, height: 3*x).fill(NSColor.blackColor()).alignBottom()
    })
    let labels = hcat(input.map { x in
        return text(width: 1, height: 0.3, text: x.0).fill(NSColor.cyanColor()).alignTop()
    })
    return bars --- labels
}
let cities = ["Shanghai": 14.01, "Istanbul": 13.3, "Moscow": 10.56, "New York": 8.33, "Berlin": 3.43]
let example3 = barGraph(cities.keysAndValues)

writepdf("example3", example3)

writepdf("example4", blueSquare ||| redSquare)
writepdf("example5", Diagram.Align(Vector2D(x: 0.5,y: 1), blueSquare) ||| redSquare)