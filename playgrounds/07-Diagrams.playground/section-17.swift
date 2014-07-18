extension Primitive {
    var size: CGSize {
        switch self {
        case .Ellipsis(let width, let height):
            return CGSizeMake(width, height)
        case .Rectangle(let width, let height):
            return CGSizeMake(width, height)
        case .Text(let width, let height, _):
            return CGSizeMake(width, height)
        }
    }
}