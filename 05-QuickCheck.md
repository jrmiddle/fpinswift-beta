

# QuickCheck

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

> "Plus should be commutative" passed 100 tests.
> ()
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

> "Minus should be commutative" doesn't hold: (1, 0)
> ()
```

Using Swift's syntax for [trailing closures](https://developer.apple.com/library/prerelease/ios/documentation/swift/conceptual/swift_programming_language/Closures.html), we can also write tests directly, without defining the property (such as `plusIsCommutative` or `minusIsCommutative`) separately:

```
check("Additive identity") {(x : Int) in x + 0 == x }

> "Additive identity" passed 100 tests.
> ()
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

First, let's write an instance for `Int`. We use the `arc4random` function from the standard library and convert it into an `Int`:

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

> 1296035768
```

To generate random strings, we need to do a little bit more work. First, we generate a random length `x` between 0 and 100. Then, we generate `x` random characters, and append them to the string:

```swift
extension String : Arbitrary {
    static func arbitrary() -> String {
        let randomLength = random(from: 0, to: 100)
        var string = ""
        for _ in 0..randomLength {
            let randomInt : Int = random(from: 13, to: 255)
            string += Character(UnicodeScalar(randomInt))
        }
        return string
    }
    
}
```

We can call it in the same way as we generate random `Int`s, except, that we call it on the `String` class:

```
String.arbitrary()

> rÇÖoàò7Ü¡ú0TAÅ¯r¾:G«
```

### Implementing the `check` function

Now we are ready to implement a first version of our check function.

```swift
func check₁<A: Arbitrary>(message: String, prop: A -> Bool) -> () {
    for _ in 0..numberOfIterations {
        let value = A.arbitrary()
        if !prop(value) {
            println("\"\(message)\" doesn't hold: \(value)")
            return
        }
    }
    println("\"\(message)\" passed \(numberOfIterations) tests.")
}
```

The `check₁` function consists of a simple loop that generates random input for the argument property in every iteration. If a counterexample is found, it is printed and the function returns; if no counterexample is found, the `check₁` function reports the number of successful tests that have passed. (Note that we called the function `check₁`, because we'll write the final version a bit later).

Here's how we can use this function to test properties:

```
check₁("Additive identity") {(x : Int) in x + 0 == x }

> "Additive identity" passed 100 tests.
> ()
```

### Making values smaller

If we run our `check₁` function on strings, we might get quite a long failure message:

```
check₁("Every string starts with Hello") {(s: String) in s.hasPrefix("Hello")}

> "Every string starts with Hello" doesn't hold: R>nþ!!3GÛ\IxhÌÅØä]:ÈæAsyz±lûàÆ®Hyÿ;MÅ¨üÔĉV7Ò<ÐIâsß«ý
> ()
```

Ideally, we'd like our failing input to be a short as possible. In general, the smaller the counterexample, the easier it is to spot which piece of code is causing the failure. In principle, the user could try to trim the input that triggered the failure and try rerunning the test; rather than place the burden on the user, however, we will automate this process.

To do so, we will make an extra protocol called `Smaller`, which does only one thing: it tries to shrink the counterexample. 

```swift
protocol Smaller {
    func smaller() -> Self?
}
```

Note that the return type of the `small` function is marked as optional. There are cases when it is not clear how to shrink test data any further. For example, there is no obvious way to shrink an empty array. We will return `nil` in that case.

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

> 50
```

For strings, we just take the substring from the first index (unless the string is empty).

```swift
extension String : Smaller {
    func smaller() -> String? {
        return self.isEmpty ? nil : self.substringFromIndex(1)
    }
}

```

To use the `Smaller` protocol in the `check` function, will need the ability to shrink any test data generated by our `check` function. To do so, we will redefine our `Arbitrary` protocol to extend the `Smaller` protocol:


```swift
protocol Arbitrary : Smaller {
    class func arbitrary() -> Self
}
```

### Iterating while we found the value

We can now redefine our `check` function to shrink any test data that triggers a failure. To do this, we use the `iterateWhile` function that takes a condition, an initial value and repeatedly applies a function as long as the condition holds.

```swift
func check₂<A: Arbitrary>(message: String, prop: A -> Bool) -> () {
    for _ in 0..numberOfIterations {
        let value = A.arbitrary()
        if !prop(value) {
            let smallerValue = iterateWhile({ value in !prop(value) }, initialValue: value) { 
              $0.smaller() 
            }
            println("\"\(message)\" doesn't hold: \(smallerValue)")
            return
        }
    }
    println("\"\(message)\" passed \(numberOfIterations) tests.")
}
```

The `iterateWhile` function is defined as follows:

```swift
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
```


### Adding support for tuples and arrays

##### ⚠ The rest of this chapter needs to be revised a bit. ⚠

Let's suppose we write a version of QuickSort in Swift:

```swift
func qsort(var array: Int[]) -> Int[] {
    if array.count == 0 { return [] }
    let pivot = array.removeAtIndex(0)
    let lesser = array.filter { $0 < pivot }
    let greater = array.filter { $0 >= pivot }
    return qsort(lesser) + [pivot] + qsort(greater)
}
```

And we can write a property to check our version of QuickSort against the built-in sort function:

```swift
check₂("qsort should behave like sort", { (x: Int[]) in return qsort(x) == sort(x) })
```

However, the compiler warns us that `Int[]` doesn't conform to the `Arbitrary` protocol.
In order to implement `Arbitrary`, we first have to implement `Smaller`:


```swift
extension Array : Smaller {
    func smaller() -> Array<T>? {
        if self.count == 0 { return nil }
        var copy = self
        copy.removeAtIndex(0)
        return copy
    }
}
```

Now, if we want to test this function, we also need an `Arbitrary` instance that produces arrays. However, to define an instance for `Array`, we also need to make sure that the element type of the array is also an instance of `Arbitrary`. For example, in order to generate an array of random numbers, we first need to make sure that we can generate random numbers.


Unfortunately, it is currently not possible to express this restriction at the type level, making it impossible to make `Array` conform to the `Arbitrary` protocol. However, what we *can* do is overload the `check` function. First, now that the compiler knows we can generate random values of `X`, we can write a function that generates a random array filled with random `X` values:

```swift
func check<X : Arbitrary>(message: String, prop : Array<X> -> Bool) -> () {
    let arbitraryArray : () -> Array<X> = {
        let randomLength = Int(arc4random() % 50)
        return Array(0..randomLength).map { _ in return X.arbitrary() }
    }
    let smaller : Array<X> -> Array<X>? = {
      return $0.smaller()
    }
    ...
}
```

Now, instead of duplicating the logic from `check₂`, we can extract a helper function. This takes an extra parameter of type `ArbitraryI<A>`, which is a struct with two functions: one for generating arbitrary values of `A`, and one for making values of `A` smaller:

```swift
func checkHelper<A>(arbitraryInstance: ArbitraryI<A>, prop: A -> Bool, message: String) -> () {
    for _ in 0..numberOfIterations {
        let value = arbitraryInstance.arbitrary()
        if !prop(value) {
            let smallerValue = iterateWhile({ !prop($0) }, initialValue: value, arbitraryInstance.smaller)
            println("\"\(message)\" doesn't hold: \(smallerValue)")
            return
        }
    }
    println("\"\(message)\" passed \(numberOfIterations) tests.")
}
```

The struct is very simple, it just wraps up the two functions. Alternatively, the functions could have been passed as parameters, but because they always belong together, it's simpler to pass them around as one value.

```swift
struct ArbitraryI<T> {
    let arbitrary : () -> T
    let smaller: T -> T?
}
```

Now, we can finish our `check` function for arrays:

```swift
func check<X : Arbitrary>(message: String, prop : Array<X> -> Bool) -> () {
    let arbitraryArray : () -> Array<X> = {
        let randomLength = Int(arc4random() % 50)
        return Array(0..randomLength).map { _ in return X.arbitrary() }
     }
    let instance = ArbitraryI(arbitrary: arbitraryArray, smaller: { $0.smaller() })
    checkHelper(instance, prop, message)
}
```

And we can write an overloaded variant of `check` that works on every type that conforms to `Arbitrary`:

```swift
func check<X : Arbitrary>(message: String, prop : X -> Bool) -> () {
    let instance = ArbitraryI(arbitrary: { X.arbitrary() }, smaller: { $0.smaller() })
    checkHelper(instance, prop, message)
}
```

Now, we can finally run `check` to verify our QuickSort implementation:

```
check("qsort should behave like sort", { (x: Int[]) in return qsort(x) == sort(x) })

> "qsort should behave like sort" passed 100 tests.
> ()
```



[^QuickCheck]: http://citeseer.ist.psu.edu/viewdoc/summary?doi=10.1.1.47.1361 "QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs"

