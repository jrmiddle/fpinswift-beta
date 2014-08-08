typealias Op = (Character, (Int, Int) -> Int)
let operatorTable : [Op] = [("*", *), ("/", /), ("+", +), ("-", -)]