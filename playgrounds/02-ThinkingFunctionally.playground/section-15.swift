func circle(radius: Double) -> Region {
    return { point in sqrt(point.x * point.x + point.y * point.y) <= radius }
}