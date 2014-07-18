// You might want to turn this down to a really low number when running this in a playground.
let numberOfIterations = 100

import Foundation

func iterateWhile<A>(condition: A -> Bool, initialValue: A, next: A -> A?) -> A {
    if let x = next(initialValue) {
        if condition(x) {
           return iterateWhile(condition,x,next)
        }
    }
    return initialValue
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

func repeat<A>(times: Int, f: Int -> A) -> [A] {
    return Array(0..<times).map(f)
}

