extension Array : Smaller {
    func smaller() -> [T]? {
        return self.count == 0 ? nil : Array(self[startIndex.successor()..<endIndex])
    }
}
