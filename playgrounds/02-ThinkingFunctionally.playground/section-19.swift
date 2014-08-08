func invert(region: Region) -> Region {
    return { point in !region(point) }
}