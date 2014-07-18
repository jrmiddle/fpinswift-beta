// You might want to turn this down to a really low number when running this in a playground.
let numberOfIterations = 100

import Foundation

func iterateWhile<A>(condition: A -> Bool, #initialValue: A, next: A -> A?) -> A {
    var value = initialValue
    while let x = next(value) {
        if condition(x) {
           value = x
        } else {
            return value
        }
    }
    return value
}

func check<X : Arbitrary>(message: String, prop : [X] -> Bool) -> () {
    let arbitraryArray : () -> [X] = {
        let randomLength = Int(arc4random() % 50)
        return Array(0..<randomLength).map { _ in return X.arbitrary() }
     }
    let instance = ArbitraryI(arbitrary: arbitraryArray, smaller: { $0.smaller() })
    checkHelper(instance, prop, message)
}

func check<X : Arbitrary>(message: String, prop : X -> Bool) -> () {
    let instance = ArbitraryI(arbitrary: { X.arbitrary() }, smaller: { $0.smaller() })
    checkHelper(instance, prop, message)
}

func check<X : Arbitrary, Y: Arbitrary>(message: String, prop: (X,Y) -> Bool) -> () {
    let arbritaryTuple = { (X.arbitrary(), Y.arbitrary()) }
    let smaller : (X,Y) -> (X,Y)? = { (x,y) in
        if let newX = x.smaller() {
            if let newY = y.smaller() {
                return (newX,newY)
            }
        }
    }
    
    let instance = ArbitraryI(arbitrary: arbritaryTuple, smaller: smaller)
    checkHelper(instance, prop, message)
}

func random (#from: Int, #to: Int) -> Int {
    return from + (Int(arc4random()) % to)
}
