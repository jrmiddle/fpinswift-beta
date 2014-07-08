extension String : Smaller {
    func smaller() -> String? {
        return self.isEmpty ? nil : self.substringFromIndex(1)
    }
}
