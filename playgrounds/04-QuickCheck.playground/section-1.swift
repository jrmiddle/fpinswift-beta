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

protocol Smaller {
    func smaller() -> Self?
}

protocol Arbitrary : Smaller {
    class func arbitrary() -> Self
}

struct ArbitraryI<T> {
    let arbitrary : () -> T
    let smaller: T -> T?
}

func checkHelper<A>(arbitraryInstance: ArbitraryI<A>, prop: A -> Bool, message: String) -> () {
    for _ in 0..<numberOfIterations {
        let value = arbitraryInstance.arbitrary()
        if !prop(value) {
            let smallerValue = iterateWhile({ !prop($0) }, value, arbitraryInstance.smaller)
            println("\"\(message)\" doesn't hold: \(smallerValue)")
            return
        }
    }
    println("\"\(message)\" passed \(numberOfIterations) tests.")
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
        return nil
    }
    
    let instance = ArbitraryI(arbitrary: arbritaryTuple, smaller: smaller)
    checkHelper(instance, prop, message)
}

func random (#from: Int, #to: Int) -> Int {
    return from + (Int(arc4random()) % (to-from))
}

func repeat<A>(times: Int, f: Int -> A) -> [A] {
    return Array(0..<times).map(f)
}

extension Int : Smaller {
    func smaller() -> Int? {
        return self == 0 ? nil : self / 2
    }
}
extension Int : Arbitrary {
    static func arbitrary() -> Int {
        return Int(arc4random())
    }
} 
extension String : Smaller {
    func smaller() -> String? {
        return self.isEmpty ? nil : self[startIndex.successor()..<endIndex]
    }
}

