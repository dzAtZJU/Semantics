import CoreGraphics

enum GDAL {
    func generateGCPArgs(gcps: [CGPoint], coordinates: [CGPoint]) -> String {
        precondition(gcps.count == coordinates.count)
        
        var s = ""
        for i in 0..<gcps.count {
            s += "-gcp \(gcps[i].x) \(gcps[i].y) \(coordinates[i].x) \(coordinates[i].y)"
        }
        return s
    }
}
