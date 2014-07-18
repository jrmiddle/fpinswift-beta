func blur(radius: Double) -> Filter {
    return { image in
        let filter = CIFilter.filter("CIGaussianBlur", parameters: [kCIInputRadiusKey: radius, kCIInputImageKey: image])
        return filter.outputImage
    }
}