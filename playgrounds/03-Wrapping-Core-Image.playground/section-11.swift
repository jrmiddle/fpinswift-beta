func compositeSourceOver(overlay: CIImage) -> Filter {
    return { image in
        let parameters : Parameters = [kCIInputBackgroundImageKey: image, kCIInputImageKey: overlay]
        let filter = CIFilter(name:"CISourceOverCompositing", 
                              parameters: parameters)
        return filter.outputImage.imageByCroppingToRect(image.extent())
    }
}