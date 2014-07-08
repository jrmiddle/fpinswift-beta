extension Int : Smaller {
    func smaller() -> Int? {
        return self == 0 ? nil : self / 2
    }
}
