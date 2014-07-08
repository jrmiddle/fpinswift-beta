extension Array : Smaller {
    func smaller() -> Array<T>? {
        if self.count == 0 { return nil }
        var copy = self
        copy.removeAtIndex(0)
        return copy
    }
}
