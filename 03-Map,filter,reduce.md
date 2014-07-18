Map, filter, reduce
=========

##### ⚠ this chapter isn't copy-edited yet, so there's no need to file issues for things like spelling mistakes. ⚠

### What this chapter is about

First-class functions are prevalent in Swift's standard library. Functions that take functions as arguments are sometimes called *higher-order* functions. In this chapter, we will tour some of the higher-order functions functions on Arrays and Dictionaries from the Swift standard library. By doing so, we will introduce Swift's *generics*, which we illustrate by writing a small library inspired by C#'s Language Integrated Queries (LINQ).

### Introducing generics


Suppose we need to write a function that, given an array of integers, computes a new array, where every integer in the original array has been incremented by one. Such a function is easy to write using a single `for` loop:

```swift
func incrementArray (xs : [Int]) -> [Int] {
    var result : [Int] = []
    for x in xs
    {
        result.append(x + 1)
    }
    return result
}
```

Now suppose we also need a function that computes a new array, where every element in the argument array has been doubled. This is also easy to do using a `for` loop:

```swift
func doubleArray1 (xs : [Int]) -> [Int] {
    var result : [Int] = []
    for x in xs
    {
        result.append(x * 2)
    }
    return result
}
```

Both these functions share a lot of code. Can we abstract over the differences and write a single, more general function that captures this pattern? Such a function would look something like this:

```swift
func computeIntArray (xs : [Int]) -> [Int] {
    var result : [Int] = []
    for x in xs
    {
        result.append(... \\ something using x)
    }
    return result
}
```

To complete this definition, we need to add a new argument describing how to compute a new integer from `xs[i]` -- that is, we need to pass a function as an argument!

```swift
func computeIntArray (xs : [Int], f : Int -> Int) -> [Int] {
    var result : [Int] = []
    for x in xs
    {
        result.append(f(x))
    }
    return result
}
```

Now we can pass different arguments, depending on how we want to compute a new array from the old array. The `doubleArray` and `incrementArray` functions become one-liners that call `computeIntArray`:

```swift
func doubleArray2 (xs : [Int]) -> [Int] {
  return computeIntArray(xs){x in x * 2}
}
```

Note that we are using Swift's syntax for trailing closures again here.

This code is still not as flexible as it could be. Suppose we want to compute a new array of booleans, describing whether the numbers in the original array were even or not. We might try to write something like:

```swift
func isEvenArray (xs : [Int]) -> [Bool] {
    computeIntArray(xs){x in x % 2 == 0}
}
```

Unfortunately, this code gives a type error. The problem is that our `computeIntArray` function takes an argument of type `Int -> Int`, function that computes a new integer. In the definition of `isEvenArray` we are passing an argument of type `Int -> Bool` which causes the type error.

How should we solve this? One thing we *could* do is define a new version of `computeIntArray` that expects takes a function argument of type `Int -> Bool`. This might look something like this:

```swift
func computeBoolArray (xs : [Int], f : Int -> Bool) -> [Bool] {
    let result : [Bool] = []
    for x in xs
    {
        result.append(f(x))
    }
    return result
}
```

This doesn't scale very well though. What if we need to compute a `String` next? Do we need to define yet another higher-order function, expecting an argument of type `Int -> String`?

Luckily there is a solution to this problem: use [*generics*](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html). The definitions of `computeBoolArray` and `computeIntArray` are identical; the only difference is in the *type signature*. If we were to define another version, `computeStringArray`, the body of the fuction would be the same again. In fact, the same code will work for *any* type. What we'd really want to do is write a single *generic* function once and for all, that will work for every possible type.

```swift
func genericComputeArray<T> (xs : [Int], f : Int -> T) -> [T] {
    var result : [T] = []
    for x in xs
    {
        result.append(f(x))
    }
    return result
}
```
The most interesting about this piece of code is its type signature. You may want to read `genericComputeArray<T>` as a family of functions; any choice of the *type* variable `T` determines a function that takes an array of integers and a function of type `Int -> T` as arguments, and returns an array of type `[T]`.

We can generalize this function even further. There is no reason for this function to operate exclusively on input arrays of type `[Int]`. Abstracting over this yields the type signature of

```swift
func map<T,U> (xs : [T], f : T -> U) -> [U] {
    var result : [U] = []
    for x in xs
    {
        result.append(f(x))
    }
    return result
}
```

Here we have written a function `map` that is generic in two dimensions: for any array of `T`s and function `f : T -> U`, it will produce a new array of `U`s. This `map` function is even more generic than the `genericComputeArray` function we have seen so far. In fact, we can define `genericComputeArray` in terms of `map`:

```swift
func genericComputeArray2<T> (xs : [Int], f : Int -> T) -> [T] {
       return map(xs,f)
}
```

Once again, the definition of the function is not that interesting: given two arguments, `xs` and `f`, apply `map` to `(xs,f)` and return the result. The types are the most interesting thing about this definition. The `genericComputeArray` is an instance of the `map` function, it only has a more specific type.

There is already a `map` method defined in the Swift standard library in the Array class. Instead of writing `map(xs,f)` for some array `xs` and function `f`, we can call the `map` function from the Array class by writing `xs.map(f)`. Here is an example definition of the `doubleArray` function using Swift's built-in `map` function:

```swift
func doubleArray3 (xs : [Int]) -> [Int] {
  return xs.map{x in 2 * x}
}
```

The point of this chapter is *not* to argue that you should define `map` yourself; we do want to argue that there is no magic involved in the definition of `map` -- you *could* have defined it yourself!


### Filter

The `map` function is not the only function in Swift's standard `Array` library that uses generics. In this section we will introduce a few others.

Suppose we have an array containing Strings, representing the contents of a directory:

```swift
let exampleFiles = ["README.md", "HelloWorld.swift", "HelloSwift.swift", "FlappyBird.swift"]
```

Now suppose we want an array of all the .swift files. This is easy to compute with a simple loop:

```swift
func getSwiftFiles(files: [String]) -> [String] {
    var result : [String] = []
    for file in files {
        if file.hasSuffix(".swift") {
            result.append(file)
        }
    }
    return result
}
```

We can now use this function to ask for the Swift files in our `exampleFiles` array:

```
getSwiftFiles(exampleFiles)

> [HelloWorld.swift, HelloSwift.swift, FlappyBird.swift]
```

Of course, we can generalize the `getSwiftFiles` function. For instance, we could pass an additional `String` argument to check against instead of hardcoding the `.swift` extension. We could then use the same function to check for `.swift` or `.md` files. But what if we want to find all the files without a file extension? Or the files starting with the string `"Hello"`?

To perform such queries, we define a general purpose `filter` function. Just as we saw previously with `map`, the `filter` function takes a *function* as an argument. This function has type `T -> Bool` -- for every element of the array this function will determine whether or not it should be included in the result.

```swift
func filter<T> (xs : [T], check : T -> Bool) -> [T] {
    var result : [T] = []
    for x in xs {
        if check(x) {
            result.append(x)
        }
    }
    return result
}
```

It is easy to define `getSwiftFiles` in terms of `filter`. Just like `map`, the `filter` function is defined in the Array class in Swift's standard library.

Now you might wonder: is there an even more general purpose function that can be used to define *both* `map` and `filter`? In the last part of this chapter, we will answer that question.

### Reduce

Once again, let's consider a few simple functions, before defining a generic function that captures the general pattern.

It is straightforward to define a function that sums all the integers in an array:

```swift
func sum(xs : [Int]) -> Int {
    var result : Int = 0
    for x in xs {
        result += x
    }
    return result
}
```

```
let xs = [1,2,3,4]
sum(xs)

> 10
```

A similar for-loop computes the product of all the integers in an array:

```swift
func product(xs : [Int]) -> Int {
    var result : Int = 1
    for x in xs {
        result = x * result
    }
    return result
}
```


Similarly, we may want to concatenate all the strings in an array:

```swift
func concatenate(xs : [String]) -> String {
    var result = ""
    for x in xs {
        result += x
    }
    return result
}
```

Or concatenate all the strings in an array, inserting a separate header line and newline characters after every element:

```swift
func prettyPrintArray (xs : [String]) -> String {
    var result = "Entries in the array xs:\n"
    for x in xs {
        result = "  " + result + x + "\n"
    }
    return result
}
```

What do all these functions have in common? They all initialize a variable, `result`, with some value. They proceed by iterating over all the elements of the input array `xs`, updating the result somehow. To define a generic function that can capture this pattern there are two pieces of information that we need to abstract over: the initial value assigned to the `result` variable; the *function* used to update the `result` in every iteration.

With this in mind, we arrive at the following definition for the `reduce` function that captures this pattern:

```swift
func reduce<A,R>(arr : [A], initialValue: R, combine: (R,A) -> R) -> R {
    var result = initialValue
    for i in arr {
        result = combine(result,i)
    }
    return result
}
```

The type of reduce is a bit hard to read at first. It is generic in two ways: for any *input array* of type `[A]` it will compute a result of type `R`. To do this, it needs an initial value of type `R` (to assign to the `result` variable) and a function `combine : (R,A) -> R` that is used to update the result variable in the body of the for loop.  In some functional languages, such as OCaml and Haskell, `reduce` functions are called `fold` or `fold_right`.

We can define every function we have seen in this chapter so far using `reduce`. Here are a few examples:

```swift
func sumUsingReduce (xs : [Int]) -> Int {
  return reduce(xs, 0) {result, x in x + result}
  }

func productUsingReduce (xs : [Int]) -> Int {
  return reduce(xs, 1) {result, x in x * result}
  }

func concatUsingReduce (xs : [String]) -> String {
  return reduce (xs, "") {result, x in x + result}
  }
```

In fact, we can even redefine `map` and `filter` using reduce:

```swift
func mapUsingReduce<T,U> (xs : [T], f : T -> U) -> [U] {
  return reduce (xs,[]) {result, x in result + [f(x)]}
}

func filterUsingReduce<T> (xs : [T], check : T -> Bool) -> [T]{
  return reduce(xs, []) {result, x in check(x) ? result + [x] : result}
}
```

This shows how the `reduce` function captures a very common programming pattern: iterating over an array to compute a result.

### Putting it all together

To conclude this section, we will give a small example of `map`, `filter` and `reduce` in action.

Suppose we have the following `struct` definition, consisting of a city's name and population (measured in thousands-of-inhabitants):
```swift
struct City {
    let name : String
    let population : Int
}
```

We can define several example cities:

```swift
let paris = City(name: "Paris", population: 2243)
let madrid = City(name: "Madrid", population: 3216)
let amsterdam = City(name: "Amsterdam", population: 811)
let berlin = City(name: "Berlin", population: 3397)

let cities = [paris, madrid, amsterdam, berlin]
```

Now suppose we would like to print a list of cities with at least one million inhabitants, together with their total population. We can define a helper function that scales up the inhabitants:

```swift
func scaleBy1000(city : City) -> City {
    return City(name: city.name, population: city.population * 1000)
}
```

Now we can use all the ingredients we have seen in this chapter to write the following statement:


```swift
cities.filter({city in city.population > 1000})
      .map(scale)
      .reduce("City : Population", {result, c in result + "\n" + "\(c.name) : \(c.population)" })
```

We start by filtering out those cities that have less than one million inhabitants; we then map our `scale` function over the remaining cities; and finally, we compute a `String` with a list of city names and populations using the `reduce` function. Here we use the `map`, `filter` and `reduce` definitions from the Array *class* in Swift's standard library. As a result, we can chain together the results of our maps and filters nicely. The `cities.filter(..)` expression computes an Array, on which we call `map`; we call `reduce` on the result of this call to obtain our final result.


