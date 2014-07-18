// <<example3>>
func barGraph(input: [(String,Double)]) -> Diagram {
    let values : [Double] = input.map { $0.1 }
    let bars =  hcat(normalize(values).map { (x: Double) -> Diagram in
        return rect(width: 1, height: 3*x).fill(NSColor.blackColor()).alignBottom()
    })
    let labels = hcat(input.map { x in
        return text(width: 1, height: 0.3, text: x.0).fill(NSColor.cyanColor()).alignTop()
    })
    return bars --- labels
}
let cities = ["Shanghai": 14.01, "Istanbul": 13.3, "Moscow": 10.56, "New York": 8.33, "Berlin": 3.43]
let example3 = barGraph(cities.keysAndValues)