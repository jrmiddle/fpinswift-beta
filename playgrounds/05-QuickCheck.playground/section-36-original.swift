extension String : Smaller {
    func smaller() -> String? {
        return self.isEmpty ? nil : self[startIndex.successor()..<endIndex]
    }
}
