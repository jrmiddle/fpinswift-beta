


# QuickCheck

####Note:  this chapter isn't copy-edited yet, so there's no need to file issues for things like spelling mistakes.

In recent years, testing has become much more prevalent in Objective-C. Many popular libraries are now tested automatically with continuous integration tools. The standard framework for writing unit tests is [XCTest](https://developer.apple.com/library/ios/documentation/ToolsLanguages/Conceptual/Xcode_Overview/UnitTestYourApp/UnitTestYourApp.html). In addition, a lot of third-party frameworks are available (such as Specta, Kiwi and FBSnapshotTestCase), and a number of frameworks are currently being developed in Swift.

All of these frameworks follow a similar pattern: they typically consist of some fragment of code, together with an expected result. The code is then executed; its result is then compared to the expected result mentioned in the test. Different libraries test at different levels: some might test individual methods, some test classes and some perform integration testing (running the entire app). In this chapter, we will build a small library for property-based testing of Swift code.


When writing unit tests, the input data is static and defined by the programmer. For example, when unit-testing an addition method, we might write a test that verifies that `1 + 1` is equal to `2`. If the implementation of addition changes in such a way that this property is broken, the test will fail. More generally, however, we might test that addition is commutative, or in other words, that `a + b` is equal to `b + a`. To test this, we might write a test case that verifies that `42 + 7` is equal to `7 + 42`.

In this chapter, we'll build Swift port (a part of) QuickCheck,[^QuickCheck] a Haskell library for random testing.  Instead of writing individual unit tests that each test a function is correct for some particular input, QuickCheck allows you to describe abstract *properties* of your functions and *generate* tests to verify them.

This is best illustrated with an example. Suppose we want to verify that plus is commutative. To do so, we start by writing a function that checks where `x + y` is equal to `y + x` for two integers `x` and `y`:

```swift
func plusIsCommutative(x : Int, y : Int) -> Bool {
    return x + y == y + x
}
```

Checking this statement with QuickCheck is as simple as calling the `check` function:

```
check("Plus should be commutative", plusIsCommutative)


```

The `check` function works by calling the `plusIsCommutative` function with two random integers, over and over again. If the statement isn't true, it will print out the input that caused the test to fail. The key insight here is that we can describe abstract *properties* of our code (like commutativity) using *functions* that return a `Bool` (like `plusIsCommutative`). The `check` function now uses this property to *generate* unit tests; giving much better code coverage than you could achieve using hand-written unit tests.

Of course, not all tests pass. For example, we can define a statement that describes that the subtraction is commutative:

```swift
func minusIsCommutative(x : Int, y : Int) -> Bool {
    return x - y == y - x
}
```

Now, if we run QuickCheck on this function, we will get a failing test case:

```
check("Minus should be commutative", minusIsCommutative)


```

Using Swift's syntax for [trailing closures](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/Closures.html), we can also write tests directly, without defining the property (such as `plusIsCommutative` or `minusIsCommutative`) separately:

```
check("Additive identity") {(x : Int) in x + 0 == x }


```

## Building QuickCheck

In order to build this library, we will need to do a couple of things. First, we need a way to generate random values for different kinds of types. Then, we need to implement the `check` function, which will feed our test with random values a number of times. Should a test fail, then we'd like to make the input smaller. For example, if our test fails on an array with 100 elements, we'll try to make it smaller and see if the test still fails. Finally, we'll need to do some extra work to make sure our check function works on types that have generics.

### Generating Random Values

First, let's define a [protocol](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/Protocols.html) that knows how to generate arbitrary values. As the return type, we use `Self`, which is the type of the class that implements it.

```swift
protocol Arbitrary {
    class func arbitrary() -> Self
}
```

First, let's write an instance for `Int`. We use the `arc4random` function from the standard library and convert it into an `Int`. Note that this only generates positive integers. A real implementation of the library would generate negative integers as well, but we'll try to keep things simple in this chapter.

```swift
extension Int : Arbitrary {
    static func arbitrary() -> Int {
        return Int(arc4random())
    }
} 
```

Now we can generate random integers like this:

```
Int.arbitrary()


```

To generate random strings, we need to do a little bit more work. First, we generate a random length `x` between 0 and 100. Then, we generate `x` random characters, and reduce them into a string. Note that we currently only generate capital letters as random characters, a real implementation would generate any kind of character.

```swift

extension Character : Arbitrary {
  static func arbitrary() -> Character {
    return Character(UnicodeScalar(random(from: 65, to:90)))
  }

  func smaller() -> Character? { return nil }
}

extension String : Arbitrary {
    static func arbitrary() -> String {
        let randomLength = random(from: 0, to: 100)
        let randomCharacters = repeat(randomLength) { _ in Character.arbitrary() }
        return reduce(randomCharacters, "", +)
    }
    
}
```


We can call it in the same way as we generate random `Int`s, except, that we call it on the `String` class:

```
String.arbitrary()


```

### Implementing the `check` function

Now we are ready to implement a first version of our check function.  The
`check1` function consists of a simple loop that generates random input for the
argument property in every iteration. If a counterexample is found, it is
printed and the function returns; if no counterexample is found, the `check1`
function reports the number of successful tests that have passed. (Note that we
called the function `check1`, because we'll write the final version a bit
later).

```swift
func check1<A: Arbitrary>(message: String, prop: A -> Bool) -> () {
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        if !prop(value) {
            println("\"\(message)\" doesn't hold: \(value)")
            return
        }
    }
    println("\"\(message)\" passed \(numberOfIterations) tests.")
}
```

Here's how we can use this function to test properties:

```
check1("Additive identity") {(x : Int) in x + 0 == x }


```

### Making values smaller

If we run our `check1` function on strings, we might get quite a long failure message:

```
check1("Every string starts with Hello") {(s: String) in s.hasPrefix("Hello")}


```

Ideally, we'd like our failing input to be a short as possible. In general, the smaller the counterexample, the easier it is to spot which piece of code is causing the failure. In this example, the counterexample is still pretty easy to understand -- but this may not always be the case! Imagine a complicated property on arrays or dictionaries that fails for some unclear reason -- debugging is much easier with a minimal counterexample. In principle, the user could try to trim the input that triggered the failure and try rerunning the test; rather than place the burden on the user, however, we will automate this process.

To do so, we will make an extra protocol called `Smaller`, which does only one thing: it tries to shrink the counterexample. 

```swift
protocol Smaller {
    func smaller() -> Self?
}
```

Note that the return type of the `smaller` function is marked as optional. There are cases when it is not clear how to shrink test data any further. For example, there is no obvious way to shrink an empty array. We will return `nil` in that case.

In our instance for integers we just try to divide the integer by two until we reach zero:

```swift
extension Int : Smaller {
    func smaller() -> Int? {
        return self == 0 ? nil : self / 2
    }
}
```

We can now test our instance:

```
100.smaller()


```

For strings, we just drop the first character (unless the string is empty).

```swift
extension String : Smaller {
    func smaller() -> String? {
        return self.isEmpty ? nil : self[startIndex.successor()..<endIndex]
    }
}

```

To use the `Smaller` protocol in the `check` function, will need the ability to shrink any test data generated by our `check` function. To do so, we will redefine our `Arbitrary` protocol to extend the `Smaller` protocol:


```swift
protocol Arbitrary : Smaller {
    class func arbitrary() -> Self
}
```

### Repeatedly shrinking

We can now redefine our `check` function to shrink any test data that triggers a failure. To do this, we use the `iterateWhile` function that takes a condition, an initial value and repeatedly applies a function as long as the condition holds.
```swift
func iterateWhile<A>(condition: A -> Bool, initialValue: A, next: A -> A?) -> A {
    if let x = next(initialValue) {
        if condition(x) {
           return iterateWhile(condition,x,next)
        }
    }
    return initialValue
}
```


Using `iterateWhile` we can now repeatedly shrink counterexamples that we uncover during testing:

```swift
func check2<A: Arbitrary>(message: String, prop: A -> Bool) -> () {
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        if !prop(value) {
            let smallerValue = iterateWhile({ value in !prop(value) }, value) { 
              $0.smaller() 
            }
            println("\"\(message)\" doesn't hold: \(smallerValue)")
            return
        }
    }
    println("\"\(message)\" passed \(numberOfIterations) tests.")
}
```


### Arbitrary Arrays

Currently, our `check2` function only supports `Int` and `String` values. While we are free to define new extensions for other types, such as `Bool`, things get more complicated when we want to generate arbitrary arrays. As a motivating example, let's  write a functional version of QuickSort:

```swift
func qsort(var array: [Int]) -> [Int] {
    if array.isEmpty { return [] }
    let pivot = array.removeAtIndex(0)
    let lesser = array.filter { $0 < pivot }
    let greater = array.filter { $0 >= pivot }
    return qsort(lesser) + [pivot] + qsort(greater)
}
```

We can also try to write a property to check our version of QuickSort against the built-in sort function:

```swift
check2("qsort should behave like sort", { (x: [Int]) in return qsort(x) == x.sorted(<) })
```

However, the compiler warns us that `[Int]` doesn't conform to the `Arbitrary` protocol.
In order to implement `Arbitrary`, we first have to implement `Smaller`. As a first step, we provide a simple definitian that drops the first element in the array:

```swift
extension Array : Smaller {
    func smaller() -> [T]? {
        return self.isEmpty ? nil : Array(self[startIndex.successor()..<endIndex])
    }
}
```


We can also write a function that generates an array of arbitrary length for any type that conforms to the `Arbitrary` protocol:

```swift
func arbitraryArray<X: Arbitrary>() -> [X] {
  let randomLength = Int(arc4random() % 50)
  return repeat(randomLength) {_ in return X.arbitrary() }
}
```

Now what we'd like to do is define an extension that uses the `abritraryArray` function to give the desired `Arbitrary` instance for arrays. However, to define an instance for `Array`, we also need to make sure that the element type of the array is also an instance of `Arbitrary`. For example, in order to generate an array of random numbers, we first need to make sure that we can generate random numbers. Ideally, we would write something like this, saying that the elements of an array should also conform to the arbitrary protocol:

```swift
extension Array<T: Arbitrary> : Arbitrary {
    static func arbitrary() -> [T] {
        ...
    }
}
```

Unfortunately, it is currently not possible to express this restriction as a type constraint, making it impossible to write an extension that makes `Array` conform to the `Arbitrary` protocol. Instead we will modify the `check2` function.

The problem with the `check2<A>` function was that it required the type `A` to be `Arbitrary`. We will drop this requirement, and instead require the necessary functions, `smaller` and `arbitrary`, to be passed as arguments.

We start by defining an auxiliary struct that contains the two functions we need:

```swift
struct ArbitraryI<T> {
    let arbitrary : () -> T
    let smaller: T -> T?
}
```

We can now write a helper function that takes such an `ArbitraryI` struct as an argument. The definition of `checkHelper` closely follows the `check2` function we saw previously. The only difference between the two is where the `arbitrary` and `smaller` functions are defined. In `check2` these were constraints on the generic type, `<A : Arbitrary>`; in `checkHelper` they are passed explicitly in the `ArbitraryI` struct:

```swift
func checkHelper<A>(arbitraryInstance: ArbitraryI<A>, 
                    prop: A -> Bool, message: String) -> () {
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
```

This is a standard technique: instead of working with functions defined in a protocol, we pass the required information as an argument explicitly. By doing so, we have a bit more flexibility. We no longer rely on Swift to *infer* the required information, but have complete control over this ourself.

We can redefine our `check2` function to use the `checkHelper` function. If we know that we have the desired `Arbitrary` definitions, we can wrap them in the `ArbitraryI` struct and call `checkHelper`:

```swift
func check<X : Arbitrary>(message: String, prop : X -> Bool) -> () {
    let instance = ArbitraryI(arbitrary: { X.arbitrary() }, smaller: { $0.smaller() })
    checkHelper(instance, prop, message)
}
```

If we have a type for which we cannot define the desired `Arbitary` instance, like arrays, we can overload the `check` function and construct the desired `ArbitraryI` struct ourself:

```swift
func check<X : Arbitrary>(message: String, prop : [X] -> Bool) -> () {
    let instance = ArbitraryI(arbitrary: arbitraryArray, 
                              smaller: { (x: [X]) in x.smaller() })
    checkHelper(instance, prop, message)
}
```

Now, we can finally run `check` to verify our QuickSort implementation. Lots of random arrays will get generated and passed to our test.

```
check("qsort should behave like sort", { (x: [Int]) in return qsort(x) == x.sorted(<) })


```

### Next steps

This library is far from complete, but already quite useful. There are a couple of obvious things that could be improved:

* The shrinking is naive. For example, in the case of arrays, we currently remove the first element of the array. However, we might also choose to remove a different element, or make the elements of the array smaller (or do all of that). The current implementation returns an optional shrinked value, whereas we might want to generate a list of values. In a [later chapter](TODO) we will see how to generate a lazy list of results, we could use the same technique here.

* The Arbitrary instances are quite simple. For different datatypes, we might want to have more complicated arbitrary instances. For example, when generating arbitrary enum values, we might want to generate certain cases with different frequencies. We might also want to generate constrained values (for example, what if we want to test a function that expects sorted arrays?). When writing multiple `Arbitrary` instances, we might want to define some helper functions that aid us in writing these instances.

* We might want to classify the generated test data. For example, if we generate a lot of arrays of length 1, we could classify this as a 'trivial' test case. The Haskell library has support for classification, these ideas could be ported directly.

There are many other small and large things that could be improved to make this into a full library.

[^QuickCheck]: http://citeseer.ist.psu.edu/viewdoc/summary?doi=10.1.1.47.1361 "QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs"




