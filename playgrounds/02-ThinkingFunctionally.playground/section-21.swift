func difference(region: Region, minusRegion: Region) -> Region {
    return intersection(region, invert(minusRegion))
}