if let myState = order.person?.address?.state? {
  print("This order will be shipped to \(myState\)")
}
else {
  print("Unknown person, address, or state.")