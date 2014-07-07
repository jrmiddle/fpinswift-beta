func intersection(region1 : Region, region2 : Region) -> Region {
    return { point in region1(point) && region2(point) }
}

func union(region1 : Region, region2 : Region) -> Region {
    return { point in region1(point) || region2(point) }
}