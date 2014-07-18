func compositeSourceOver(overlay: CIImage) -> Filter {
    return { image in
        let filter = CIFilter.filter("CISourceOverCompositing", parameters: [kCIInputBackgroundImageKey: image, kCIInputImageKey: overlay])
        return filter.outputImage.imageByCroppingToRect(image.extent())
    }
}