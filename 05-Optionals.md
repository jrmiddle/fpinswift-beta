# Optionals

####Note:  this chapter isn't copy-edited yet, so there's no need to file issues for things like spelling mistakes.


## What this chapter is about

Swift's *optional types* can be used to represent values that may be missing or computations that may fail. This chapter describes Swift's optional types, how to work with them effectively, and how they fit well with the functional programming paradigm.

## Case study: Dictionaries

Besides arrays, Swift has special support for working with *dictionaries*. A dictionary is collection of key-value pairs, providing an efficient way to find the value associated with a certain key. The syntax for creating dictionaries is similar to arrays:

```swift
let cities = ["Paris" : 2243, "Madrid" : 3216, "Amsterdam" : 881, "Berlin" : 3397]
```

Similar to the previous example in Chapter 3, this dictionary stores the population of several European cities. In this example, the key `"Paris"` is associated with the value `2243`; that is, Paris has about `2243000` inhabitants.

Like arrays, the `Dictionary` type is generic. The type of dictionaries is generic in two arguments: the types of the stored keys and values. In our example, the city dictionary has type `Dictionary<String,Int>`. There is also a shorthand notation, `[String : Int]`.

We can lookup the value associated with a key using the same notation as array indexing:

```swift
let madridPopulation : Int = cities["Madrid"]
```

This example, however, does not type check. The problem is that the key `"Madrid"` may not be in the `cities` dictionary -- and what value should be returned if it is not? We cannot guarantee that the dictionary lookup operation *always* returns an `Int` for every key. Swift's *optional* types track the possibility of failure. The correct way to write the example above would be:

```swift
let madridPopulation : Int? = cities["Madrid"]
```

Instead of having type `Int`, the `madridPopulation` example has type the optional type `Int?`. A value of type `Int?` is either an `Int` or a special 'null' value, `nil`.

We can check whether or not the lookup was successful as follows:

```swift
if madridPopulation {
  println("The population of Madrid is \(madridPopulation! * 1000)")
}
else {
  println("Unknown city: Madrid")
}
```

If  `madridPopulation` is not `nil`, the then branch is executed. To refer to the underlying `Int`, we write `madridPopulation!`. The post-fix `!` operator forces an optional to a non-optional type. To compute the total population of Madrid, we force the optional `madridPopulation` to an `Int` and mutiply by `1000`.

Swift has a special *optional binding* mechanism, that lets you avoid writing the `!` suffix. We can combine the definition of `madridPopulation` and the check above into a single statement:

```swift
if let madridPopulation = cities["Madrid"] {
  println("The population of Madrid is \(madridPopulation! * 1000)")
}
else {
  println("Unknown city: Madrid")
}
```

If the lookup, `cities["Madrid"]`, is succesful we can use the variable `madridPopulation : Int` may be used in the then branch. Note that we no longer need to explicitly use the forced unwrapping operator.

Given the choice, we'd recommend using option binding over forced unwrapping. Forced unwrapping may crash if you have a `nil` value; option binding encourages you to handle exceptional cases explicitly, avoiding run-time errors. Unchecked usage of the forced unwrapping of optional types is a bad code smell. Similarly, Swift's mechanism for [implicitly unwrapped optionals](https://developer.apple.com/library/prerelease/mac/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html) is also unsafe and should be avoided whenever possible.

## Combining optional values

Swift's optional values make the possibility of failure explicit. This can be cumbersome, especially when combining several optional results. There are several techniques to facilitate the use of optionals.

### Optional chaining

First of all, Swift has a special mechanism, *optional chaining*, for selecting methods or attributes in nested classes or structs. Consider the following (fragment of) a model for processing customer orders:

```
struct Order {
    let orderNumber : Int
    let person : Person?
    ...
}

struct Person {
    let name : String
    let address? : Address
    ...
}

struct Address{
    let streetName : String
    let city : String
    let state : String?
    ...
}
```

Given an `Order`, how can we find the state of the customer? We could use the explicit unwrapping operator:

```swift
order.person!.address!.state!
```

Doing so, however, may cause run-time exceptions if any of the intermediate data is missing. It would be much safer to use option binding:

```swift
if let myPerson = order.person in {
  if let myAddress = myPerson.address in {
    if let myState = myAddress.state in {
    ...
```

But this is rather verbose. Using optional chaining, this example would become:

```swift
if let myState = order.person?.address?.state? {
  print("This order will be shipped to \(myState\)")
}
else {
  print("Unknown person, address, or state.")
```

Instead of forcing the unwrapping of intermediate types, we use the question mark operator to try and unwrap the optional types. When any of the component selections fails, the whole chain of selection statements returns `nil`.

### Maps and monads


The `?` operator lets us select methods or fields of optional values. There are plenty of other examples, however, where you may want to manipulate an optional value, if it exists, and return `nil` otherwise. Consider the following example:

```swift
func incrementOptional (maybeX : Int?) -> Int? {
  if let x = maybeX {
    return x + 1
  }
  else {
    return nil
  }
}
```

The `incrementOptional` example behaves similarly to the `?` operator: if the optional value is nil, the result is nil; otherwise there some computation is performed.

We can generalize both `incrementOptional` and the `?` operator and define a `map` operator on optionals as follows:

```swift
func map<T,U> (maybeX : T?, f : T -> U) -> U? {
  if let x = maybeX {
    return f(x)
  }
  else {
    return nil
  }
}
```

This `map` function takes two arguments: an optional value of type `T?` and a function `f` of type `T -> U`. If the optional value is non-nil, it applies f to it and returns the result; otherwise the `map` function returns nil. This `map` function is part of the Swift standard library.

Using `map` we write the `incrementOptional` function as:

```swift
func incrementOptional2 (maybeX : Int?) -> Int? {
    return maybeX.map{x in x + 1}
}
```

Of course, we can also use `map` to project fields or methods from optional structs and classes, similar to the `?` operator.


The `map` function shows one way to manipulate optional values, but many others exist. Consider the following example:

```swift
let x : Int? = 3
let y : Int? = nil
let z : Int? = x + y
```

This program is not accepted by the Swift compiler. Can you spot the error?

The problem is that addition only works on `Int` values, rather than the optional `Int?` values we have here. To resolve this, we would have to introduce nested `if` statements as follows:

```swift
func addOptionals (maybeX : Int?, maybeY : Int?) -> Int? {
  if let x = maybeX {
    if let y = maybeY {
        return x + y}
    }
  return nil
}
```

This may seem like a contrived example, but manipulating optional values can happen all the time. Suppose we have the following dictionary, associating capital cities with their inhabitants:

```swift
let capitals = ["France" : "Paris", "Spain" : "Madrid", "The Netherlands" : "Amsterdam", "Belgium" : "Brussels"]
```

We might want to compose this dictionary with the `cities` dictionary we saw previously, to write a function that computes the number of inhabitants in a countries capital city, if we have the information necessary to compute this:

```swift
func populationOfCapital (country : String) -> Int? {
  if let capital = capitals[country] {
    if let population = cities[capital] {
      return population * 1000
    }
  }
}
```

The same pattern pops up again, repeatedly checking if an optional exists, and continuing with some computation when it does. In a language with first-class functions, like Swift, we define a custom operator that captures this pattern:

```swift
operator infix >>= {}

@infix func >>= <U,T> (maybeX : T?, f : T -> U?) -> U? {
    if let x = maybeX
    {
        return f(x)
    }
    else
    {
        return nil
    }
}
```

The `>>=` operator checks whether some optional value is non-nil. If it is, we pass it on to the argument function `f`; if the optional argument is nil, the result is also nil.

Using this operator, we can now write our examples as follows:

```swift
func addOptionals (maybeX : Int?, maybeY : Int?) -> Int? {
    maybeX >>= {x in
    maybeY >>= {y in
    x + y}}
  }

func populationOfCapital (country : String) -> Int? {
    capitals[country] >>= {capital in
    cities[capital] >>= {population in
    return population * 1000}}
}
```

The choice of operator, `>>=`, name is no coincidence. Swift's optional types are an example of a *monad*, similar to Haskell's `Maybe` type. We will call a type that expects a generic argument a *type constructor*. For example, the array type expects an additional generic argument in order to be well-formed; `Array<T>` or `Array<Int>` are valid types, but `Array` by itself is not. A monad is a type constructor `M` that supports a pair of functions with the following types:

```swift
  func return<U> (x : U) -> M<U>
  
  @infix func >>= <U,T> (x : M<T>, f : T -> M<U>) -> M<U>
```

Although we haven't defined the `return` function for optionals, it is trivial to do so.

We do not want to advocate that `>>=` is 'right' way to combine optional values, or that you need to understand monads to work with Swift's optionals. Instead we hope to show that optionals are not a new idea. They have successfully been used in other languages for many years. The optional binding mechanism captures just the right pattern for writing most functions over optionals -- and for good reason: it corresponds to the `>>=` operation of the optional monad.


## Why Optionals?

What's the point of introducing an explicit optional type? For programmers used to Objective C, working with optional types may seem strange at first. The Swift type system is rather rigid: whenever we have an optional type, we have to deal with the possibility of it being `nil`. We have had to write new functions like `map` to manipulate optional values. In Objective C, you have more flexibility. For instance, when we translate the example above to Objective C, there is no compiler error:

```objc
- (int)populationOfCapital:(NSString *)country {
    return [self.cities[self.capitals[country]] intValue] * 1000;
}
```

We can pass in the nil for the name of a country, and we get back a result of `0.0`. Everything is fine. In many languages without optionals, null pointers are a source of danger. Much less so in Objective-C. In Objective-C, you can safely send messages to nil, and depending on the return type, you either get nil, 0, or similar "zero-like" values. Why change this behavior in Swift?

The choice for an explicit optional type fits with the increased static safety of Swift. A strong type system catches errors before code is executed; automatic memory allocation and garbage collection limits the possibility for memory leaks; an explicit optional type helps protects you from unexpected crashes arising from nil values.

The default "zero-like" behaviour employed by Objective-C has its drawbacks. You may want to distinguish between failure (a key is not in the dictionary) and success-returning-zero (a key is in the dictionary, but associated with 0). Furthermore, the behavior is not available to all types: you cannot have an integer that might be nil without wrapping it in a class like `NSNumber`.

While it is safe in Objective-C to send messages to nil, it is often not safe to use them. Let's say we want to create an attributed string. If we pass in nil as the argument for `country`, the `capital` will also be nil, but `NSAttributedString` will crash when trying to initialize it with a nil value.

```objective-c
- (NSAttributedString *)attributedCapital:(NSString*)country {
    NSString *capital = self.capitals[country];
    return [[NSAttributedString alloc] initWithString:capital 
                                           attributes:self.capitalAttributes];
}
```

While crashes like that don't happen too often, almost every developer had code like this crash. Most of the time, these crashes are detected during debugging, but it is very possible to ship code without noticing that in some cases a variable might unexpectedly be nil. Therefore, many programmers use asserts to verify this behavior. For example, we can add a `NSParameterAssert` to make sure we crash quickly when the `country` is nil:

```objective-c
- (NSAttributedString *)attributedCapital:(NSString*)country {
    NSParameterAssert(country);
    NSString *capital = self.capitals[country];
    return [[NSAttributedString alloc] initWithString:capital 
                                           attributes:self.capitalAttributes];
}
```

Now, when we pass in a country value that is nil, the assert fails immediately, and we are almost certain to hit this during debugging. But what if we pass in a `country` value that doesn't have a matching key in `self.capitals`? This is much more likely, especially when `country` comes from user input. In that case, `capital` will be nil and our code will still crash. Of course, this can be fixed easily enough. The point is, however, that it is easier to write *robust* code using nil in Swift than in Objective-C.

Finally, using these assertions is inherently non-modular. Suppose we implement a `checkCountry` method, that checks that a non-nil `NSString*` is supported. We can incorporate this check easily enough:

```objective-c
- (NSAttributedString *)attributedCapital:(NSString*)country {
    NSParameterAssert(country);
    if (checkCountry(country))
    ...
}
```

Now the question arises: should the `checkCountry` function also assert that its argument is non-nil. On the one hand, it should not: we have just performed the check in the `attributedCapital` method. On the other hand, if the `checkCountry` function only works on non-nil values, we should duplicate the assertion. We are forced to choose between exposing an unsafe interface or duplicating assertions.

In Swift, things are quite a bit better. Function signatures using optionals explicitly state which values may be nil. This is invaluable information when working with other people's code. A signature like the following provides a lot of information:

```swift
func attributedCapital(country : String) -> NSAttributedString?
```

Not only are we warned about the possibility of failure, but we know that we must pass a `String` as argument -- and not a nil value. A crash like the one we described above will not happen. Furthermore, this is information *checked* by the compiler. Documentation goes out of date easily; you can always trust function signatures.


