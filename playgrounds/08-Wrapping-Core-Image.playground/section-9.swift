func colorGenerator(color: NSColor) -> Filter {
    return { _ in
        let filter = CIFilter.filter("CIConstantColorGenerator", parameters: [kCIInputColorKey: color])
        return filter.outputImage
    }
}