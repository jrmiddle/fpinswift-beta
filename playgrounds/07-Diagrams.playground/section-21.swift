func fit(alignment: Vector2D, inputSize: CGSize, rect: CGRect) -> CGRect {
    let div = rect.size / inputSize
    let scale = min(div.width, div.height)
    let size = scale * inputSize
    let space = alignment.size * (size - rect.size)
    let result = CGRect(origin: rect.origin - space.point, size: size)
    return result
}