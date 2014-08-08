# Wrapping Core Image

####Note:  this chapter isn't copy-edited yet, so there's no need to file issues for things like spelling mistakes.

## What this chapter is about

The previous chapter introduced the concept of *higher-order function* and showed how functions can be passed as arguments to other functions. The example, however, may seem far removed from the 'real' code that you write on a daily basis. In this chapter, we will show how to use higher-order functions to write a small, functional wrapper around an existing, object-oriented API.

Core Image is a powerful image processing framework, but its API can be a bit clunky to use at times. The Core Image API is loosely typed -- image filters are configured using key-value-coding. It is all too easy to make mistakes in the type or name of arguments, which can result in run-time errors. The new API we develop will be safe and modular, exploiting *types* to guarantee the absence of runtime errors.

Don't worry if you're unfamiliar with Core Image or cannot understand all details of the code fragments in this chapter. The goal isn't too build a complete wrapper around Core Image, but instead to illustrate how concepts from functional programming, such as higher-order functions, can be applied in production code.


## The Filter Type

One of the key classes in Core Image is the `CIFilter` class, used to create image filters. When you instantiate a `CIFilter` object, you (almost) always provide an input image via the `kCIInputImageKey` key and then retrieve the filtered result via the `kCIOutputImageKey` key. Then you can use this result as input for the next filter. 

In the API we will develop in this chapter, we'll try to encapsulate the exact details of these keys-value pairs and present a safe, strongly-typed API to our users. We define our own `Filter` type as a function that takes an image as parameter and returns a new image:


```swift
typealias Filter = CIImage -> CIImage
```

This is the base type that we are going to build upon. 


## Building Filters

Now that we have the `Filter` type defined, we can start defining functions that build specific filters. These are convenience functions that take the parameters needed for a specific filter and construct a value of type `Filter`. These functions will all have the following general shape:

    func myFilter(/* parameters */) -> Filter

Note that the return value, `Filter`, is a function as well. This will help us later on to compose multiple filters to achieve the image effects we want.

To make our lives a bit easier, we'll extend the `CIFilter` class with a convenience initializer and a computed property to retrieve the output image:

```swift
typealias Parameters = Dictionary<String, AnyObject>

extension CIFilter {

    convenience init(name: String, parameters: Parameters) {
        self.init(name: name)
        setDefaults()
        for (key, value : AnyObject) in parameters {
            setValue(value, forKey: key)
        }
    }

    var outputImage: CIImage { return self.valueForKey(kCIOutputImageKey) as CIImage }

}
```

The convenience initializer takes the name of the filter and a dictionary as parameters. The key-value pairs in the dictionary will be set as parameters on the new filter object. Our convenience initializer follows the Swift pattern of calling the designated initializer first.

The [computed property](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Properties.html#//apple_ref/doc/uid/TP40014097-CH14-XID_329) `outputImage` provides an easy way to retrieve the output image from the filter object. It looks up the `kCIOutputImageKey` key in and casts the result to a value of type `CIImage`. By providing this computed property of type `CIImage`, users of our API no longer need to cast the result of such a lookup operation themselves.


### Blur

With these pieces in place, we can define our first simple filters. The gaussian blur filter only has the blur radius as parameter. Therefore we can write a blur `Filter` very easily:

```swift
func blur(radius: Double) -> Filter {
    return { image in
        let parameters : Parameters = [kCIInputRadiusKey: radius, kCIInputImageKey: image]
        let filter = CIFilter(name:"CIGaussianBlur", parameters:parameters)
        return filter.outputImage
    }
}
```

That's all there is to it. The `blur` function returns a function that takes an argument `image` of type `CIImage` and returns a new image (`return filter.outputImage`). Therefore the return value of the `blur` function conforms to the `Filter` type we have defined previously as `CIImage -> CIImage`.

This example is just a thin wrapper around a filter that already exists in Core Image. We can use the same pattern over and over again to create our own filter functions.


### Color Overlay

Let's define a filter that overlays an image with a solid color of our choice. Core Image doesn't have such a filter by default, but we can of course compose it from existing filters.

The two building blocks we're going to use for this is the color generator filter (`CIConstantColorGenerator`) and the source over compositing filter (`CISourceOverCompositing`). Let's first define a filter to generate a constant color plane:

```swift
func colorGenerator(color: NSColor) -> Filter {
    return { _ in
        let filter = CIFilter(name:"CIConstantColorGenerator", 
                              parameters: [kCIInputColorKey: color])
        return filter.outputImage
    }
}
```

This looks very similar to the `blur` filter we've defined above with one notable difference: the constant color generator filter does not inspect its input image. Therefore we don't need to name the image parameter in the function being returned; instead we use an unnamed parameter, `_`, to emphasise that the image argument to the filter we are defining is ignored.

Next, we're going to define the composite filter:

```swift
func compositeSourceOver(overlay: CIImage) -> Filter {
    return { image in
        let parameters : Parameters = [kCIInputBackgroundImageKey: image, kCIInputImageKey: overlay]
        let filter = CIFilter(name:"CISourceOverCompositing", 
                              parameters: parameters)
        return filter.outputImage.imageByCroppingToRect(image.extent())
    }
}
```

Here we crop the output image to the size of the input image. This is not strictly necessary and depends on how we want the filter to behave. This choice works well in the examples we will cover.

Finally we combine these two filters to create our color overlay filter:

```swift
func colorOverlay(color: NSColor) -> Filter {
    return { image in
        let overlay = colorGenerator(color)(image)
        return compositeSourceOver(overlay)(image)
    }
}
```

Once again, we return a function that takes an image parameter as its argument. The `colorOverlay` starts by calling the `colorGenerator` filter. The `colorGenerator` filter requires a `color` as its argument and returns a filter; hence the code snippet `colorGenerator(color)` has type `Filter`. The `Filter` type, however, is itself a function from `CIImage` to `CIImage`; we can pass an *additional* argument of type `CIImage` to `colorGenerator(color)` to compute a new overlay `CIImage`. This is exactly what happens in the definition of `overlay` -- we create a filter using the `colorGenerator` function and pass the `image` argument to this filter to create a new image. Similarly, the value returned, `compositeSourceOver(overlay)(image)`, consists of a filter being constructed, `compositeSourceOver(overlay)`, and subsequently being applied to the `image` argument.

## Composing Filters

Now that we have a blur and a color overlay filter defined, we can put them to use on an actual image in a combined way: first we blur the image and then we put a red overlay on top. Let's load an image to work on:

```swift
let url = NSURL(string: "https://lh4.googleusercontent.com/-YCRFnjDOiwk/AAAAAAAAAAI/AAAAAAAAAAA/akhx39n7XyA/photo.jpg");
let image = CIImage(contentsOfURL: url)
```

Now we can apply both filters to these by chaining them together:

```swift
let blurRadius = 5.0
let overlayColor = NSColor.redColor().colorWithAlphaComponent(0.2)
let blurredImage = blur(blurRadius)(image)
let overlaidImage = colorOverlay(overlayColor)(blurredImage)
```

Once again, we assemble images by creating a filter, such as `blur(blurRadius)`, and applying the resulting filter to an image.

### Function Composition

Of course we could simply combine the two filter calls in the above code in a single expression:

```swift
let result = colorOverlay(overlayColor)(blur(blurRadius)(image))
```

This becomes unreadable very quickly with all these parentheses involved. A nicer way to do this is to compose filters by defining a custom operator for filter composition. To do so, we'll start by defining a function that composes filters:

```swift
func composeFilters(filter1: Filter, filter2: Filter) -> Filter {
    return {img in filter1(filter2(img)) }
}
```

The `composeFilters` function takes two argument filters and defines a new filter. This composite filter expects an argument `img` of type `CIImage`, and passes it through both `filter2` and `filter1` respectively. We can use function composition to define our own composite filter like this:

```swift
let myFilter1 = composeFilters(blur(blurRadius), colorOverlay(overlayColor))
let result1 = myFilter1(image)
```

We can even go one step further to make this even more readable by introducing an operator for filter composition. Granted, defining your own operators all over the place doesn't necessarily contribute to the readability of your code, but filter composition is such a recurring pattern that it makes a lot of sense to do this at this point:

```swift
infix operator |> { associativity left }

func |> (filter1: Filter, filter2: Filter) -> Filter {
    return {img in filter1(filter2(img))}
}
```

Now we can use the `|>` operator in the same way we have used the `composeFilters` before:

```swift
let myFilter2 = blur(blurRadius) |> colorOverlay(overlayColor)
let result2 = myFilter2(image)
```

The `|>` notation is borrowed from F#. The filter composition operation that we have defined is an example of *function composition*. In mathematics, the composition of two functions `f` and `g`, sometimes written `f ∘ g`, defines a new function mapping an input to `x` to `f(g(x))`. This is precisely what our `|>` operator does -- it passes an argument image through its two constituent filters.

## Theoretical background: currying

In this chapter, we've seen that there are two ways to define a function that takes two arguments. The first style is familiar to most programmers:

```swift
func add1(x:Int, y : Int) -> Int {
  return x + y
}
```

The `add1` function takes two integer arguments and returns their sum. In Swift, however, we can also define another version of the same function:

```swift
func add2(x : Int) -> (Int -> Int) {
  return {y in return x + y}
}
```

Here the function `add2` takes one argument, `x`, and returns a *closure*, expecting a second argument `y`. These two `add` functions must be invoked differently:

```
add1(1,2)
add2(1)(2)


```

In the first case, we pass both arguments to `add1` at the same time; in the second, we first pass the first argument `1`, which returns a function, which we apply to the second argument `2`. Both versions are equivalent: we can define `add1` in terms of `add2` and visa versa.

In this fashion, we can always transform a function that expects multiple arguments into a series of functions that each expect one argument. This process is referred to as *currying*, named after the logician Haskell Curry; we say that `add2` is the *curried* version of `add1`. The popular functional programming language Haskell, which you may have heard of, is also named after Haskell Curry.

In Swift, we can even leave out some of the parentheses in the type signature of `add2`, and write:

```swift
func add2(x : Int) -> Int -> Int {
  {y in return x + y}
}
```

The function arrow, `->`, associates to the right. That is to say, you can read the type `A -> B -> C` as `A -> (B -> C)`. Throughout this book, however, we will typically introduce a typealias for functional types (as we did for the `Region` and `Filter` types) or write explicit parentheses.

## Discussion

This example illustrates, once again, how we break complex code into small pieces, which can all be reassembled using function application. The goal of this chapter was not to define a complete API around Core Image, but instead to sketch how higher-order functions and function composition can be used in a more practical case study.

Why go through all this effort? The Core Image API is already mature and provides all the functionality you might need. We believe there are several advantages to the API designed in this chapter:

- **Safety** -- using the API we have sketched, it is almost impossible to create runtime errors arising from undefined keys or failed casts.
- **Modularity** -- it is easy to compose filters using the `|>` operator. Doing so allows you to tease apart complex filters into smaller, simpler, reusable components.
- **Clarity** -- even if you have never used Core Image, you should be able to assemble simple filters using the functions we have defined. You don't need to know about special dictionary keys to access the results, such as `kCIOutputImageKey`, or worry about initialising certain keys, such as `kCIInputImageKey` or `kCIInputRadiusKey`. From the types alone, you can almost figure out how to use the API, even without further documentation.

Our API presents a series of functions that can be used to define and compose filters. Any filters that you define are safe to use and reuse. Each filter can be tested and understood in isolation. We believe these are compelling reasons to favor the design sketched here over the original Core Image API. 

