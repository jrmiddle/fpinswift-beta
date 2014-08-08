func colorGenerator(color: NSColor) -> Filter {
    return { _ in
        let filter = CIFilter(name:"CIConstantColorGenerator", 
                              parameters: [kCIInputColorKey: color])
        return filter.outputImage
    }
}