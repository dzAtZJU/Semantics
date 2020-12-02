import UIKit

extension UIImage {
    static func createPointImage(colors: [UIColor]) -> UIImage {
        let r: CGFloat = 9
        let d = 2 * r
        let span = 2 * CGFloat.pi / CGFloat(colors.count)
        let center = CGPoint(x: r, y: r)
        
        // 90
        // |
        // |
        // |
        // |__________ 0
        return UIGraphicsImageRenderer(size: .init(width: d, height: d)).image { context in
            var startAngle = -CGFloat.pi * 0.5
            for i in 0..<colors.count {
                context.cgContext.move(to: center)
                let endAngle = startAngle + span
                context.cgContext.addArc(center: center, radius: r, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                context.cgContext.setFillColor(colors[i].cgColor)
                context.cgContext.fillPath()
                
                startAngle = endAngle
            }
        }
    }
}
