import CoreGraphics

public enum Geometry {
    public static func boundingBox(ofPolygon polygon: [CGPoint]) -> CGRect {
        var minX = CGFloat.infinity
        var minY = minX
        var maxX = -CGFloat.infinity
        var maxY = maxX
        
        for point in polygon {
            minX = min(point.x, minX)
            maxX = max(point.x, maxX)
            minY = min(point.y, minY)
            maxY = max(point.y, maxY)
        }
        
        return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
    }
    
//    static func transformPolygonAspectFit(targetSize: CGSize, polygon: [CGPoint], isOrginAtUpperLeft: Bool = false) -> CGRect {
//        var transformation = CGAffineTransform.identity
//        if !isOrginAtUpperLeft {
//            transformation = transformation.concatenating(CGAffineTransform(scaleX: 1, y: -1))
//        }
//
//        let rotation = CGAffineTransform.identity//CGAffineTransform(rotationAngle: CGFloat.pi/3)
//        transformation = transformation.concatenating(rotation)
//
//        var boundingBox = Self.boundingBoxOfPolygon(polygon, transformation: transformation)
//        let translation = CGAffineTransform(translationX: -boundingBox.minX, y: -boundingBox.minY)
//        boundingBox = boundingBox.applying(translation)
//        transformation = transformation.concatenating(translation)
//
//        let fillingSize = targetSize.kf.filling(boundingBox.size)
//        let scale = targetSize.height / fillingSize.height
//        let scaling = CGAffineTransform(scaleX: scale, y: scale)
//        transformation = transformation.concatenating(scaling)
//
////        return transformation
//        return boundingBox
//    }
}

