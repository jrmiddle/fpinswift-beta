
// *****************************************************************
// These are convenience functions to make sure the code above works
// *****************************************************************

import Cocoa

extension NSGraphicsContext {
   var cgContext : CGContextRef {
       let opaqueContext = COpaquePointer(self.graphicsPort)
       return Unmanaged<CGContextRef>.fromOpaque(opaqueContext).takeUnretainedValue()
   }
}

func *(l: CGPoint, r: CGRect) -> CGPoint {
    return CGPointMake(r.origin.x + l.x*r.size.width, r.origin.y + l.y*r.size.height)
}

func *(l: CGFloat, r: CGPoint) -> CGPoint { return CGPointMake(l*r.x, l*r.y) }
func *(l: CGFloat, r: CGSize) -> CGSize { return CGSizeMake(l*r.width, l*r.height) }

func pointWise(f: (CGFloat,CGFloat)->CGFloat, l: CGSize, r: CGSize) -> CGSize {
    return CGSizeMake(f(l.width,r.width), f(l.height,r.height))
}
func pointWise(f: (CGFloat,CGFloat)->CGFloat, l: CGPoint, r:CGPoint) -> CGPoint {
    return CGPointMake(f(l.x,r.x), f(l.y,r.y))
}

func /(l:CGSize, r:CGSize) -> CGSize { return pointWise(/, l, r) }
func *(l:CGSize, r:CGSize) -> CGSize { return pointWise(*, l, r) }
func +(l:CGSize, r:CGSize) -> CGSize { return pointWise(+, l, r) }
func -(l:CGSize, r:CGSize) -> CGSize { return pointWise(-, l, r) }

func -(l: CGPoint,r: CGPoint) -> CGPoint { return pointWise(-,l, r) }
func +(l: CGPoint,r: CGPoint) -> CGPoint { return pointWise(+,l,r) }
func *(l: CGPoint,r: CGPoint) -> CGPoint { return pointWise(*,l,r) }


extension CGSize {
    var point : CGPoint {
      return CGPointMake(self.width, self.height)
    }
}

func isHorizontalEdge(edge: CGRectEdge) -> Bool {
    switch edge {
    case .MaxXEdge, .MinXEdge:
        return true
    default:
        return false
    }
}


func splitRect(rect: CGRect, sizeRatio: CGSize, edge: CGRectEdge) -> (CGRect, CGRect) {
    let ratio = isHorizontalEdge(edge) ? sizeRatio.width : sizeRatio.height
    let multiplier = isHorizontalEdge(edge) ? rect.width : rect.height
    let distance : CGFloat = multiplier * ratio
    var mySlice : CGRect = CGRectZero
    var myRemainder : CGRect = CGRectZero
    CGRectDivide(rect, &mySlice, &myRemainder, distance, edge)
    return (mySlice, myRemainder)
}

func splitHorizontal(rect: CGRect, ratio: CGSize) -> (CGRect, CGRect) {
    return splitRect(rect, ratio, CGRectEdge.MinXEdge)
}

func splitVertical(rect: CGRect, ratio: CGSize) -> (CGRect, CGRect) {
    return splitRect(rect, ratio, CGRectEdge.MinYEdge)
}


extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPointMake(center.x - size.width/2, center.y - size.height/2), size: size)
    }
}

// A 2-D Vector
struct Vector2D {
    let x: CGFloat
    let y: CGFloat
    
    var point : CGPoint { return CGPointMake(x, y) }
    
    var size : CGSize { return CGSizeMake(x, y) }
}

func *(m: CGFloat, v: Vector2D) -> Vector2D {
    return Vector2D(x: m*v.x, y: m*v.y)
}

extension Dictionary {
    var keysAndValues : [(Key,Value)] {
        var result : [(Key,Value)] = []
        for item in self {
            result.append(item)
        }
        return result
    }
}

func normalize(input: [CGFloat]) -> [CGFloat] {
    let maxVal = input.reduce(0) { max($0,$1) }
    return input.map { $0/maxVal }
}
