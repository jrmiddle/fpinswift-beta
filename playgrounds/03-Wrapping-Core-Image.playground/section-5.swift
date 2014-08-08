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