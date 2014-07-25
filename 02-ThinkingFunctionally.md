# Thinking Functionally

####Note:  this chapter isn't copy-edited yet, so there's no need to file issues for things like spelling mistakes.


## What this chapter is about

Functions in Swift are *first-class values*, i.e., functions may be passed as arguments to other functions. This idea may seem strange if you're used to working with simple types, such as integers, booleans or structs. In this chapter, we will try to motivate why first-class functions are useful and give a first example of functional programming in action.


## Example: Battleship

We'll introduce first-class functions using the example of an algorithm you would implement if you would want to create a Battleship-like game.[^ARPA] The problem we'll look at boils down to determining whether or not a given point is in range, without being too close to friendly ships or ourselves.

As a first approximation, you might write a very simple function that checks whether or not a point is in range. For the sake of simplicity, we will assume that our ship is located at the origin. We can visualize the region we want to describe as follows:

![](battleship-1.png)

The first function we write, `inRange1` checks when a point is in the grey area in the picture above. Using some basic geometry, we can write this function as follows:



```swift
typealias Position = CGPoint
typealias Distance = CGFloat

func inRange1(target: Position, range: Distance) -> Bool {
   return sqrt(target.x * target.x + target.y * target.y) <= range
}
```

Note that we are using Swift's [typealias](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Types.html) construct let us introduce a new name for an existing type. From now on, whenever we write `Position`, feel free to read `CGPoint`, a pair of an `x` and `y` coordinate.

Now this works fine, if you assume that the we are always located at the origin. Suppose the ship may be at a location, `ownposition`, other than the origin. We can update our visualization to look something like this:

![](battleship-2.png)


We now add an argument representing the location of the ship to our `inRange` function:

```swift
func inRange2(target: Position, ownPosition: Position, range: Distance) -> Bool {
   let dx = ownPosition.x - target.x
   let dy = ownPosition.y - target.y
   return sqrt(dx * dx + dy * dy) <= range
}
```

But now you realize that you also want to avoid targeting ships if they are too close to yourself. We can update our picture to illustrate the new situation, where we want to target only those enemies that are at least `minD` away from our current position:

![](battleship-3.png)

As a result, we need to modify our code again:

```swift
let minimumDistance : Distance = 2.0

func inRange3(target: Position, ownPosition: Position, range: Distance) -> Bool {
   let dx = ownPosition.x - target.x
   let dy = ownPosition.y - target.y
   return sqrt(dx * dx + dy * dy) <= range
          && sqrt(dx * dx + dy * dy) >= minimumDistance
}
```

Finally, you also need to avoid targeting ships that are too close to one of your other ships. We can visualize this by as follows:

![](battleship-4.png)

Correspondingly, we can add a further argument that represents the location of a friendly ship to our `inRange` function:

```swift
func inRange4(target: Position, ownPosition: Position, friendly: Position, range: Distance) -> Bool {
   let dx = ownPosition.x - target.x
   let dy = ownPosition.y - target.y
   let friendlyDx = friendly.x - target.x
   let friendlyDy = friendly.y - target.y
   return sqrt(dx * dx + dy * dy) <= range
          && sqrt(dx * dx + dy * dy) >= minimumDistance
          && !(sqrt(friendlyDx * friendlyDx + friendlyDy * friendlyDy) >= minimumDistance)
}
```

As this code evolves, it becomes harder and harder to maintain. This method expresses a complicated calculation in one big lump of code. Let's try to refactor this into smaller, compositional pieces.


## First-class functions

There are different approaches to refactoring this code. One obvious pattern would be to introduce a function that computes the distance between two points; or functions that check when two points are 'close' or 'far away' (for some definition of close and far). In this chapter, however, we'll take a slightly different approach.

The original problem boiled down to defining a function that determined when a point was in range or not. The type of such a function would be something like:

```
func pointInRange(point: Position) -> Bool {
    // Implement method here
}
```

The type of this function is going to be so important, that we're going to give it a separate name:

```swift
typealias Region = Position -> Bool
```

From now on, the `Region` type will refer to functions from a `Position` to a `Bool`. This isn't strictly necessary, but it can make some of the type signatures that we'll see below a bit easier to digest. 

Instead of defining an object or struct to represent regions, we represent a region by a *function* that determines if a given point is in the region or not. If you're not used to functional programming this may seem strange, but remember: functions in Swift are first-class values! We conciously choose the name `Region` for this type rather than something like `CheckInRegion` or `RegionBlock`. These names suggest that they denote a function type; yet the key philosophy underlying *functional programming* is that functions are values, no different from structs, Ints or Bools -- using a separate naming convention for functions would violate this philosophy. 

We will now write several functions that create, manipulate and combine regions. 

The first region we define is a `circle`, centered around the origin:

```swift
func circle(radius: Distance) -> Region {
    return { point in sqrt(point.x * point.x + point.y * point.y) <= radius }
}
```

Note that, given a radius `r`, the call `circle(r)` *returns a function*. Here we use Swift's [notation for closures](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Closures.html) to construct the function that we wish to return. Given an argument position, `point`, we check that the `point` is in the region delimited by a circle of the given radius centered around the origin.

Of course, not all circles are centered around the origin. We could add more arguments to the `circle` function to account for this. Instead, though, we will write a *region transformer:*

```swift
func shift(offset: Position, region: Region) -> Region {
    return { point in
        let shiftedPoint = Position(x: point.x - offset.x, y: point.y - offset.y)
        return region(shiftedPoint)
    }
}
```

The call `shift(offset, region)` moves the region to the right and up by `offet.x` and `offset.y` respectively. How is it implemented? Well we need to return a `Region`, that is a function from points to `Bool`. To do this, we start writing another closure, introducing the point we need to check. From this point, we compute a new point with the coordinates `point.x - offset.x` and `point.y - offset.y`. Finally, we check that this new point is in the *original* region by passing it as an arguments to the `region` function.

Interestingly, there are lots of other ways to transform existing regions. For instance, we may want to define a new region by inverting a region. The resulting region consists of all the points outside the original region:

```swift
func invert(region: Region) -> Region {
    return { point in !region(point) }
}
```

We can also write functions that combine existing regions into larger, complex regions. For instance, these two functions take the points that are in *both* argument regions or *either* argument region, respectively:

```swift
func intersection(region1 : Region, region2 : Region) -> Region {
    return { point in region1(point) && region2(point) }
}

func union(region1 : Region, region2 : Region) -> Region {
    return { point in region1(point) || region2(point) }
}
```

Of course, we can use these functions to define even richer regions. The `crop` function takes two regions as argument, `region` and `minusRegion`, and constructs a region with all points that are in the first, but not in the second region.

```swift
func difference(region: Region, minusRegion: Region) -> Region {
    return intersection(region, invert(minusRegion))
}
```

This example shows how Swift lets you compute and pass around functions no differently than integers or booleans.

Now let's turn our attention back to our original example. With this small library in place, we can now refactor the complicated `inRange` function as follows:

```swift
func inRange(ownPosition: Position, target: Position, friendly: Position, range: Distance) -> Bool {
  let targetRegion = shift(ownPosition, difference(circle(range), circle(minimumDistance)))
  let friendlyRegion = shift(friendly, circle(minimumDistance))
  return difference(targetRegion, friendlyRegion)(target)
}
```

The way we've defined the `Region` type does have its disadvantages. In particular, we cannot inspect *how* a region was constructed: is it composed of smaller regions? Or is it simply a circle around the origin? The only thing we can do is to check whether or not a given point is within a region or not. If we would want to visualize a region, we would have to sample enough points to generate a (black and white) bitmap. 



## Type-driven development

In the introduction, we mentioned how functional programs take the application of functions to arguments as the canonical way to assemble bigger programs. In this chapter, we have seen a concrete example of this functional design methodology. We have defined a series of functions for describing regions. Each of these functions is not very powerful by itself. Yet together, they can describe complex regions that you wouldn't want to write from scratch.

The solution is simple and elegant. It is quite different from what you might write, had you just refactored the `inRange4` function into separate methods. The crucial design decision we made was *how* to define regions. Once we chose the `Region` type, all the other definitions followed naturally. The moral of the example is **choose your types carefully**. More than anything else, types guide the development process. 

[^ARPA]: The code presented here is inspired by the Haskell solution to a problem posed by the ARPA documented here: Hudak, Paul, and Mark P. Jones. *Haskell vs. Ada vs. C++ vs. awk vs.... an experiment in software prototyping productivity*. Technical report, Yale University, Dept. of CS, New Haven, CT, 1994.

