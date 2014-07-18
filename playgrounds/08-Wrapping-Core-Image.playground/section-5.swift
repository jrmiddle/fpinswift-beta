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