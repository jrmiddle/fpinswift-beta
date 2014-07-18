extension Array : Smaller {
    func smaller() -> [T]? {
        return self.isEmpty ? nil : Array(self[startIndex.successor()..<endIndex])
    }
}