func circle(radius: Distance) -> Region {
    return { point in sqrt(point.x * point.x + point.y * point.y) <= radius }
}