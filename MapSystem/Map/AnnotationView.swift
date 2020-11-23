import UIKit

struct AnnotationView {
    static func createPointImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 14, height: 14)
        return UIGraphicsImageRenderer(size: size).image { context in
            UIImage(systemName:"circle.fill")!.withTintColor(color).draw(in:CGRect(origin:.zero, size: size))
        }
    }
}
