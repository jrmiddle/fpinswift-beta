# Generators and Sequences

## What this chapter is about

In this chapter, we'll look at generators and sequences. These form the machinery underlying Swift's for-loops and will be the basis of our parsing library, that we will present in the following chapters.

## Generators

In Objective-C and Swift, we almost always use the Array datatype to represent a list of items. It is both simple and fast. There are situations, however, where Arrays are not suitable. For example, you might not want to calculate all the elements of an the Array – because there are infinitely many or you don’t expect to use them all. In such situations, you may want to use a *generator* instead.

We will try to provide some motivation for generators, using familiar examples from array computations. Swift's for-loops can be used to iterate over array elements:

```swift
for x in xs {
    \\ do something with x
}
```

In such a for-loop, the array is traversed from beginning to end. There may be examples, however, where you want to traverse arrays in a different order. This is one example where *generators* may be useful.

Conceptually, a generator is 'process' that generates new array elements on request. A generator is any type that adheres to the following protocol:

```swift
protocol GeneratorType {
    typealias Element
    func next() -> Element?
}
```

This protocol requires an *associated type*, `Element`, defined by the `GeneratorType`. There is a single method, `next`, that produces the next element, if it exists, and nil otherwise.

For example, the following generator produces array indices, starting from the end of an array until it reaches 0:

```swift

class CountdownGenerator : GeneratorType {
    
    typealias Element = Int
    
    var element : Element
    
    init<T>(array:[T]) {
        self.element = array.count - 1
    }

    init(start:Int) {
        self.element = start
    }

    func next() -> Element? {
        return self.element < 0 ? nil : element--
    }
}
```

For the sake of convenience we provide two initializers: one that counts down from an initial number `start`; the other is passed an array and initializes the `element` to the the array's last valid index.

We can use this `CountdownGenerator` to traverse an array backwards:

```swift
let xs = ["A","B","C"]
let generator = CountdownGenerator(array:xs)
while let i = generator.next() {
    println("Element \(i) of the array is \(xs[i])")
}
```

Althought it may seem like overkill on such simple examples, the generator encapsulates the computation of array indices. If we want to compute the indices in a different order, we only need to update the generator and never the code that uses it.

Generators need not produce a nil value at some point. For example, we can define a generator that produces an infinite series of powers of 2:

```swift
class PowerGenerator : GeneratorType {

    typealias Element = Int

    var power : Int = 1

    func next() -> Element? {
        let result = power
        power *= 2
        return result
    }
}
```

We can use the `PowerGenerator` to inspect increasingly large array indices, for example, when implementing a exponential search algorithm which doubles the array index in every iteration.

We may also want to use the `PowerGenerator` for something entirely different. Suppose we want to search through the powers of two, looking for some interesting value. The `findPower` function takes a `predicate` of type `Int -> Bool` as argument and returns the smallest power of two that satisfies this predicate:

```swift
func findPower(predicate : Int -> Bool) -> Int {
    let g = PowerGenerator()
    while let x = g.next() {
        if predicate(x) {
            return x
        }
    }
    return 0;
}
```

We can use the `findPower` function to compute the smallest power of two larger than 1000:

```
findPower{x in x >= 1000}


```

The generators we have seen so far all produce elements of type `Int`, but this need not be the case. We can equally well write generators that produce some other value. For example, the following generator produces a list of Strings, corresponding to the lines of a file.


```swift
class FileLinesGenerator : GeneratorType
{
    typealias Element = String
    
    var lines : [String]
    
    init(filename : String) {
        if let contents = String.stringWithContentsOfFile(filename,
                                                          encoding: NSASCIIStringEncoding,
                                                          error: nil) {
            let newLine = NSCharacterSet.newlineCharacterSet()
            lines = contents.componentsSeparatedByCharactersInSet(newLine)
        } else {
            lines = []
        }
    }
    
    func next() -> Element? {
        if let nextLine = lines.first {
            lines.removeAtIndex(0)
            return nextLine
        } else {
            return nil
        }
    }
    
}
```

By defining generators in this fashion, we separate the *generation* of data from its *usage*. The generation may involve opening a file or URL and handling the errors that may arise. Hiding this behind a simple generator protocol, helps keep the code that manipulates the generated data oblivious to these issues.

By defining a protocol for generators, we can also write functions that are *generic* over any generator. For instance, our previous `findPower` function can be generalized as follows:

```swift
func find <G : GeneratorType> (var generator : G, 
                               predicate : G.Element -> Bool) -> G.Element? {
                               
    while let x = generator.next() {
        if predicate(x) {
            return x
        }
    }
    return nil
}
```

The `find` function is generic over any possible generator. The most interesting thing about it, is its type signature. The `find` function takes two arguments: a generator and a predicate. The generator may be modified by the find function, resulting from the calls to `next`, and hence we need to add the `var` attribute in the type declaration. The predicate should be a function mapping generated elements to `Bool`. We can refer to the generator's associated type as `G.Element` in the type signature of `find`. Finally, note that we may not succeed finding a value that satisfies the predicate. For that reason, `find` returns optional value, returning nil when the generator is exhausted.

It is also possible to combine generators on top of one another. For example, you may want to limit the number of items generated, buffer the generated values, or encrypt the data generated somehow. Here is one simple example of a generator transformer that produces at most `limit` values from its argument generator:

```swift
class LimitGenerator<G : GeneratorType> : GeneratorType
{
    typealias Element = G.Element
    var limit = 0
    var generator : G

    init (limit : Int, generator : G) {
        self.limit = limit
        self.generator = generator
    }
    
    func next() -> Element? {
        if limit >= 0 {
            limit--
            generator.next()
        }
        else {
            return nil
        }
    }
}
```

Such a generator may be useful to populate an array of fixed size or buffer the elements generated somehow.


When writing generators, it can sometimes be cumbersome to introduce new classes for every generator. Swift provides a simple struct, `GeneratorOf<T>`, that is generic in the element type. It can be initialized with a `next` function:

```swift
struct GeneratorOf<T> : GeneratorType, SequenceType {
    init(next: () -> T?)
    ...
```

We will provide the complete definition of `GeneratorOf` shortly. For
now, we'd like to point out that the `GeneratorOf` struct not only
implements the `GeneratorType` protocol, but also implements the
`SequenceType` protocol that we will cover in the next section.

Using `GeneratorOf` allows for much shorter definitions of generators. For example, we can rewrite our `CountdownGenerator` as follows:

```swift
func countDown(start:Int) -> GeneratorOf<Int> {
    var i = start
    return GeneratorOf {return i < 0 ? nil : i--}
}
```

We can even define functions to manipulate and combine generators in terms of `GeneratorOf`. For example, we can append two generators with the same underlying element type as follows:

```swift
func +<A>(var first: GeneratorOf<A>, var second: GeneratorOf<A>) -> GeneratorOf<A> {
    return GeneratorOf {
        if let x = first.next() {
            return x
        } else if let x = second.next() {
            return x
        }
        return nil
    }
}
```

The resulting generator simply reads off new elements from its `first` argument generator; once this is exhausted, it produces elements from its `second` generator. Once both generators have returned nil, the composite generator also returns nil.

## Sequences

Generators form the basis of another Swift protocol, *sequences*. Generators provide a 'one-shot' mechanism for repeatedly computing a next element. There is no way to rewind or replay the elements generated. The only thing we can do is create a fresh generator and use that instead. The `SequenceType` protocol provides just the right interface for doing that:

```swift
protocol SequenceType {
    typealias Generator : GeneratorType
    func generate() -> Generator
}
```

Every sequence has an associated generator type and a method to create a new generator. We can then use this generator to traverse the sequence. For example, we can use our `CountdownGenerator` to define a sequence that generates a series of array indexes in back-to-front order:

```swift
struct ReverseSequence<T> : SequenceType {
    var array : [T]
    
    init (array : [T]) {
        self.array = array
    }
    
    typealias Generator = CountdownGenerator
    func generate() -> Generator {
        return CountdownGenerator(array:array)
    }
}
```

Every time we want to traverse the array stored in the `ReverseSequence` struct, we can call the `generate` method to produce the desired generator. The following example shows how to fit these pieces together:

```swift
let reverseSequence = ReverseSequence(array:xs)
let reverseGenerator = reverseSequence.generate()
while let i = reverseGenerator.next() {
  print("Index \(i) is \(xs[i])")
}
```

In contrast to the previous example that just used the generator, the *same* sequence can be traversed a second time -- we would simply call `generate` to produce a new generator.


Swift has special syntax for working with sequences. Instead of creating the generator associated with a sequence yourself, you can write a for-in loop. For example, we can also write the previous code snippet as:

```swift
for i in ReverseSequence(array:xs) {
  print("Index \(i) is \(xs[i])")
}
```

Under the hood, Swift then uses the `generate` method to produce a generator and repeatedly call its `next` function until it produces nil. 

The obvious drawback of our `CountdownGenerator` is that it produces numbers, while we may be interested in the *elements* associated with an array. Fortunately there are standard `map` and `filter` functions that manipulate sequences rather than arrays:

```swift
func filter<S : SequenceType>
  (source: S, includeElement: (S.Generator.Element) -> Bool) -> [S.Generator.Element]

func map<S : SequenceType, T>
  (source: S, transform: (S.Generator.Element) -> T) -> [T]
```

To produce the *elements* of an array in reverse order, we can `map` over our `ReverseSequence`:

```swift
let reverseElements = map(ReverseSequence(array:xs)){i in xs[i]}
for x in reverseElements {
  print("Element is \(x)")
}
```

Similarly, we may of course want to filter out certain elements from a sequence.

It is worth pointing out that these `map` and `filter` functions do *not* return new sequences, but traverse the sequence to produce an array. Mathematicians may therefore object to calling such an operation a `map` as it fails to leave the underlying structure (a sequence) intact. There are separate versions of `map` and `filter` that do produce sequences. These are defined as extensions of the `LazySequence` class. A `LazySequence` is simple wrapper around regular sequences:

```swift
func lazy<S : SequenceType>(s: S) -> LazySequence<S>
```

If you need to map or filter sequences that may produce infinite results or many results that you may not be interested in, be sure to use a `LazySequence` rather than a `Sequence`. Failing to do so could cause your program to diverge or take much longer than you might expect.




## Case study: Better shrinking in QuickCheck

In this section we will give a somewhat larger case study of defining sequences by improving the `Smaller` protocol we implemented in the QuickCheck chapter. Originally, the protocol was defined as follows:


```swift
protocol Smaller {
    func smaller() -> Self?
}
```

We used the `Smaller` protocol to try and shrink counterexamples that our testing uncovered. The `smaller` function was repeatedly called to generate a smaller value, if this value also fails the test it was considered a 'better' counterexample than the original one. The `Smaller` instance we defined for arrays simply tried to repeatedly strip off the first element:

```swift
extension Array : Smaller {
    func smaller() -> [T]? {
        return self.isEmpty ? nil : Array(self[startIndex.successor()..<endIndex])
    }
}
```

While this will certainly help shrink counterexamples in *some* examples, there are many different ways to shrink an array. Computing all possible sub-arrays is quite an expensive operation. For an array of length `n` there are `2^n` possible sub-arrays that may or may not be interesting counterexamples: generating and testing them is not a good idea.

Instead, we will show how to use a generator to produce a series of smaller values. We can then adapt our QuickCheck library to use the following protocol:

```swift
protocol Smaller {
    func smaller() -> GeneratorOf<Self>
}
```

When QuickCheck finds a counterexample, we can then rerun our tests on the series of smaller values, until we have found a suitably small counterexample. The only thing we still have to do, is write a `smaller` function for arrays (and any other type that we might want to shrink).

As a first step, instead of removing just the first element of the array, we will compute a series of arrays, where each new array has one element removed. This will not produce all possible sublists, but only a sequence of arrays that are all one element shorter than the original array. Using `GeneratorOf`, we can define such a function as follows:

```swift
func removeAnElement<T>(var array: [T]) -> GeneratorOf<[T]> {
    var i = 0
    return GeneratorOf {
        if i < array.count {
            var result = array.self
            result.removeAtIndex(i)
            i++
            return result
        }
        return nil
    }
}
```

The `removeAnElement` function keeps track of a variable `i`. When asked for a next element, it checks whether or not `i` is less than the length of the array. If so, it computes a new array, `result`, and increments `i`. If we have reached the end of our original array, we return nil. Note that we duplicate the array using `array.self` to ensure that elements that are removed in one iteration are still present in the next.

We can now see that this returns all possible arrays that are one element smaller:

```swift
removeAnElement([1,2,3])
```

Unfortunately, this call does not produce the desired result -- it defines a `GeneratorOf<[Int]>`, while we would like to see an array of arrays. Fortunately, there is an `Array` initializer that takes a `Sequence` as argument. Using that initializer, we can test our generator as follows:

```
Array(removeAnElement([1,2,3]))


```

### A more functional approach

Before we refine the `removeElement` function further, we will rewrite it in a more functional way. The implementation of `removeElement` we gave above uses quite some explicit copying of arrays and mutable state. We have already seen that working with data types and recursion forms a powerful technique for decomposing problems into smaller pieces. While the Array type is not a data type, we can define a pattern matching principle on it ourselves:


```swift
extension Array {
    var match : (head: T, tail: [T])? {
      return (count > 0) ? (self[0],Array(self[1..<count])) : nil
    }
}
```

In case of an empty array, `match` returns `nil`; when the array is non-empty array, it returns a tuple with the first element and the rest of the array. We can use this to define recursive traversals of arrays. For example, we can sum the elements of an array recursively, without using a for-loop or reduce, as follows:

```swift
func sum(xs : [Int]) -> Int {
    if let (head,tail) = xs.match
    {
        return (head + sum(tail))
    } else {
        return 0
    }
}
```

Of course, this may not be a very good example: a function like `sum` is easy to write using `reduce`. This is not true for all functions on arrays. For example, consider the problem of inserting a new element into a sorted array. Writing this using `reduce` is not at all easy; writing it as a recursive function is fairly straightforward:

```swift
func insert(x : Int, xs : [Int]) -> [Int] {
    if let (head,tail) = xs.match
    {
        return (x <= head ? [x] + xs : [head] + insert(x,tail))
    } else {
        return [x]
    }
}
```


Before we can return to our original problem, how to shrink an array, we need one last auxiliary definition. In the Swift standard library, there is a `GeneratorOfOne` struct that can be useful for wrapping an optional value as a generator:

```swift
struct GeneratorOfOne<T> : GeneratorType, SequenceType {
    init(_ element: T?)
    ...
```

Given an optional element, it generates the sequence with just that element (provided it is non-nil):

```
let three : [Int] = Array(GeneratorOfOne(3))
let empty : [Int] = Array(GeneratorOfOne(nil))


```

For the sake of convenience, we will define our own little wrapper function around `GeneratorOfOne`:

```swift
func one<X>(x: X?) -> GeneratorOf<X> {
    return GeneratorOf(GeneratorOfOne(x))
}
```

Now we finally return to our original problem, redefining the `smaller` function on arrays. If we try to formulate a recursive pseudocode definition of what our original `removeElement` function computed we might arrive at something along the following lines:

* If the array is empty, return nil;
* If the array can be split into a head and tail, we can recursively compute the remaining sub-arrays as follows:
    - tail of the array is a sub-array
    - if we prepend `head` to all the sub-arrays of the tail, we can compute the sub-arrays of the original array.

We can translate this algorithm directly into Swift with the functions we have defined:

```swift
func smaller1<T>(array: [T]) -> GeneratorOf<[T]> {
    if let (head,tail) = array.match {
        let gen1 : GeneratorOf<[T]> = one(tail)
        let gen2 : GeneratorOf<[T]> = map(smaller1(tail),{smallerTail in [head] + smallerTail})
        return gen1 + gen2
    } else {
        return one(nil)
    }
}
```

We're now ready to test our functional variant, and we can verify that it's the same result as `removeAnElement`:

```
Array(smaller1([1,2,3]))


```

Note that there is one thing we should point out. In this definition of `smaller` we are using our own version of `map`:

```swift
func map<A,B>(var g: GeneratorOf<A>, f: A -> B) -> GeneratorOf<B> {
    return GeneratorOf {
        g.next().map(f)
    }
}
```

You may recall that the `map` and `filter` methods from the standard library return a `LazySequence`. To avoid the overhead of wrapping and unwrapping these lazy sequences, we have chosen to manipulate the `GeneratorOf` directly.

There is one last improvement worth making. There is one more way to try and reduce the counterexamples that QuickCheck finds. Instead of just removing elements, we may also want to try and shrink the elements themselves. To do that, we need to add a condition that `T` conforms to the smaller protocol.


```swift
func smaller<T : Smaller>(ls: [T]) -> GeneratorOf<[T]> {
  if let (head, tail) = ls.match {
        let gen1 : GeneratorOf<[T]> = one(tail)
        let gen2 : GeneratorOf<[T]> = map(smaller(tail), {xs in [head] + xs})
        let gen3 : GeneratorOf<[T]> = map(head.smaller(), {x in [x] + tail})
        return gen1 + gen2 + gen3
  } else {
    return one(nil)
  }
}
```

We can check the results of our new `smaller` function.

```
Array(smaller([1,2,3]))


```

Besides generating sublists, this new version of the `smaller` function also produces arrays where the values of the elements is smaller.

## Beyond map and filter

In the coming chapter we will need a few more operations on sequences and generators. We have already defined a concatenation, `+`, on generators. Can we use this definition to concatenate sequences?

We might try to reuse our `+` operation on generators when concatenating sequences as follows:

```swift
func +<A>(l: SequenceOf<A>, r: SequenceOf<A>) -> SequenceOf<A> {
  return SequenceOf(l.generate() + r.generate())
}
```

This definition calls the generate method of the two argument sequences, concatenates these, and assigns the resulting generator to the sequence. Unfortunately, it does not quite work as expected. Consider the following example:

```swift
let s = SequenceOf([1,2,3]) + SequenceOf([4,5,6])
println("First pass:")
for x in s {
    print(x)
}
println("\nSecond pass:")
for x in s {
    print(x)
}
```

We construct a sequence containing the elements `[1,2,3,4,5,6]` and traverse it twice, printing the elements we encounter. Somewhat suprisingly perhaps, this code produces the following output:

```
First pass:
123456
Second pass:
```

The second for loop is not producing any output -- what went wrong? The problem is in the definition of concatenation on sequences. We assemble the desired generator, `l.generate() + r.generate()`. This generator produces all the desired elements in the first loop in the example above. Once it has been exhausted, however, traversing the compound sequence a second time will not produce a fresh generator, but instead use the generator that has already been exhausted.

Fortunately, this problem is easy to fix. We need to ensure that the result of our concatenation operation can produce new generators. To do so, we pass a *function* that produces generators, rather than a fixed generator to the `SequenceOf` initializer:

```
func +<A>(l: SequenceOf<A>, r: SequenceOf<A>) -> SequenceOf<A> {
  return SequenceOf { l.generate() + r.generate() }
}
```

Now, we can iterate over the same sequence multiple times. When writing your own methods that combine sequences, it is important to ensure that every call to `generate()` produces a fresh generator that is oblivious to any previous traversals.

So far we can concatenate two sequences. What about flattening a sequence of sequences? Before we deal with sequences, let's try writing a `join` operation on generators that, given a `GeneratorOf<GeneratorOf<A>>`, produces a `GeneratorOf<A>`:

```swift
struct JoinedGenerator<A> : GeneratorType {
    typealias Element = A
    
    var generator: GeneratorOf<GeneratorOf<A>>
    var current: GeneratorOf<A>?
    
    init(_ g: GeneratorOf<GeneratorOf<A>>) {
        generator = g
        current = generator.next()
    }
    
    mutating func next() -> A? {
        if var c = current {
            if let x = c.next() {
                return x
            } else {
                current = generator.next()
                return next()
            }
        }
        return nil
    }
}
```

This `JoinedGenerator` maintains two pieces of mutable state: an optional `current` generator and the remaining `generators`. When asked to produce the next element, it calls the `next` function on the current generator, if it exists. When this fails, it updates the `current` generator and *recursively* calls `next` again. Only when all the generators have been exhausted, does the `next` function return nil.

Next, we use this `JoinedGenerator` to join a sequence of sequences:

```swift
func join<A>(s: SequenceOf<SequenceOf<A>>) -> SequenceOf<A> {
    return SequenceOf {JoinedGenerator(map(s.generate()) {g in g.generate()})}
}
```

The argument of `JoinedGenerator` may look complicated, but it does very little. When struggling to understand an expression like this, following the types is usually a good way to learn what it does. We need to provide an argument closure producing a value of type `GeneratorOf<GeneratorOf<A>>`; calling `s.generate()` gets us part of the way there, producing a value of type `GeneratorOf<SequenceOf<A>>`. The only thing we need to do is call `generate` on all the sequences inside the resulting generators, which is precisely what the call to `map` accomplishes. 

Finally, we can also combine `join` and `map` to write the following `flatmap` function:

```swift
func flatmap<A,B>(xs: SequenceOf<A>, f: A -> SequenceOf<B>) -> SequenceOf<B> {
    return join(map(xs,f))
}
```

Given a sequence of `A` elements, and a function `f` that, given a single value of type `A`, produces a new sequence of `B` elements, we can build a single sequence of `B` elements. To do so, we simply map `f` over the argument sequence, constructing a `SequenceOf<SequenceOf<B>>`, which we `join` to obtain the desired `SequenceOf<B>`.

Now, we've got a good grip on sequences and the operations they support, we can start to write our parser combinator library.





