# Wrapping Core Image

####Note:  this chapter isn't copy-edited yet, so there's no need to file issues for things like spelling mistakes.

Core Image is a powerful image processing framework, but its API can be a bit clunky to use at times. The Core Image API is loosely typed -- image filters are configured using key-value-coding. It is all too easy to make mistakes in the type or name of arguments, which can result in run-time errors.

In this chapter we will develop a functional API, wrapped around the (object-oriented) Core Image framework. As a result, we can create and chain filters easily, while improving the static guarantees about our filters at the same time.


## The Filter Type

When you instantiate a `CIFilter` object, you (almost) always provide an input image via the `kCIInputImageKey` key and then retrieve the filtered result via the `kCIOutputImageKey` key. Then you can use this result as input for the next filter. 

So we can define a filter simply as a function that takes an image as parameter and returns an image:


```swift
typealias Filter = CIImage -> CIImage
```

This is the base type that we are going to build upon. 


## Building Filters

Now that we have the `Filter` type defined, we can start building functions defining specific filters. These are convenience functions that take the parameters needed for a specific filter and construct a value of type `Filter`. These functions will all have the following general shape:

    func myFilter(/* parameters */) -> Filter

Note that the return value, `Filter`, is a function as well. This will help us later on to compose multiple filters to achieve the image effects we want.

To make our lives a bit easier, we'll extend the `CIFilter` class with a convenience initializer and a computed property to retrieve the output image:

```swift
extension CIFilter {

    class func filter(name: String, parameters: Dictionary<String, AnyObject>) -> CIFilter {
        let filter = self(name: name)
        filter.setDefaults()
        for (key, value : AnyObject) in parameters {
            filter.setValue(value, forKey: key)
        }
        return filter;
    }

    var outputImage: CIImage { return self.valueForKey(kCIOutputImageKey) as CIImage }

}
```

The convenience initializer takes the name of the filter and a dictionary as parameters. The key-value pairs in the dictionary will be set as parameters on the new filter object. As a convenience initializer we follow the Swift pattern of calling the designated initializer first.

The [computed property](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Properties.html#//apple_ref/doc/uid/TP40014097-CH14-XID_329) is an easy way to retrieve the output image from the filter object. But it also makes sure that the output image has a defined type (`CIImage`), so that we don't have to write `as CIImage` all over the place in our code.


### Blur

The gaussian blur filter only has the blur radius as parameter. Therefore we can write a blur `Filter` very easily:

```swift
func blur(radius: Double) -> Filter {
    return { image in
        let filter = CIFilter.filter("CIGaussianBlur", parameters: [kCIInputRadiusKey: radius, kCIInputImageKey: image])
        return filter.outputImage
    }
}
```

That's all there is to it. The `blur` function returns a function that takes an image as parameter (`image in`...) and returns an image (`return filter.outputImage`). Therefore the return value of the `blur` function conforms to the `Filter` type we have defined as `CIImage -> CIImage`.

This example is just a thin wrapper around a filter that already exists in Core Image. We can use the same pattern to create our own filter functions that do more than that.


### Color Overlay

Let's define a filter that overlays an image with a solid color of our choice. Core Image doesn't have such a filter by default, but we can of course compose it from existing filters.

The two building blocks we're going to use for this is the color generator filter (`CIConstantColorGenerator`) and the source over compositing filter (`CISourceOverCompositing`). Let's first define a filter to generate a constant color plane:

```swift
func colorGenerator(color: NSColor) -> Filter {
    return { _ in
        let filter = CIFilter.filter("CIConstantColorGenerator", parameters: [kCIInputColorKey: color])
        return filter.outputImage
    }
}
```

This looks very similar to the `blur` filter we've defined above, with one notable difference: the constant color generator filter actually does not take an image as input. Therefore we don't need the image parameter in the returned `Filter` function and we can use an unnamed parameter as input (`_ in`...). 

Next, we're going to define the composite filter:

```swift
func compositeSourceOver(overlay: CIImage) -> Filter {
    return { image in
        let filter = CIFilter.filter("CISourceOverCompositing", parameters: [kCIInputBackgroundImageKey: image, kCIInputImageKey: overlay])
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

Notice how we use the filter functions: `blur(blurRadius)(image)`. The first part of this expression (`blur(blurRadius)`) returns a *function* of type `CIImage -> CIImage`, which we then call with `image` as parameter.

Rather than using these filters one after the other, it would be handy if we could easily define a custom composite filter that can be applied at once.


### Function Composition

Of course we could simply combine the two filter calls in the above code in a single expression:

```swift
let result = colorOverlay(overlayColor)(blur(blurRadius)(image))
```

But this becomes unreadable very quickly with all these parenthesis going on. A nicer way to do this is to use function composition. First we write a function that takes two other functions as input and returns a combined function as output:

```swift
func composeFunctions <A, B, C>(func1: B -> C, func2: A -> B) -> (A -> C) {
    return {arg in func1(func2(arg)) }
}
```

Here we use Swift's [generics](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html) to make the definition more flexible than we might need in this specific example. The `composeFunctions` function takes two parameters: one function of type `B -> C` and another function of type `A -> B` (with `A`, `B`, and `C` may be any type). From those two functions we construct a new function of type `A -> C`, that passes its argument `arg` of type `A` to the second function, producing a value of type `B`. This value is then passed to the first function, producing the desired value of type `C`. We can use function composition to define our own composite filter like this:

```swift
let myFilter1 = composeFunctions(blur(blurRadius), colorOverlay(overlayColor))
let result1 = myFilter1(image)
```

We can even go one step further to make this even more readable by introducing an operator for function composition. Granted, defining your own operators all over the place doesn't necessarily contribute to the readability of your code, but function composition is such a common pattern in functional programming that it makes a lot of sense to do this at this point:

```swift
operator infix |> { associativity left }

func |> <A, B, C>(func1: B -> C, func2: A -> B) -> (A -> C) {
    return { func1(func2($0)) }
}
```

Now we can use the `|>` operator in the same way we have used the `composeFunction` before:

```swift
let myFilter2 = blur(blurRadius) |> colorOverlay(overlayColor)
let result2 = myFilter2(image)
```

This example illustrates, once again, how we break complex code into small pieces, which can all be reassembled using function application.

