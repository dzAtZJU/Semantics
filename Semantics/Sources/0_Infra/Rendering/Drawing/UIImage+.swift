import UIKit
import CoreGraphics

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

extension UIImage {
    func masking(polygon: [CGPoint]) -> UIImage {
        precondition(polygon.count >= 3)
        precondition(polygon.first! == polygon.last!)
        let renderer = UIGraphicsImageRenderer(size: size)
        let mask =  UIGraphicsImageRenderer(size: size).image { context in
//            context.cgContext.setFillColor(CGColor(gray: 0, alpha: 0))
//            context.cgContext.fill(.init(origin: .zero, size: size))
            
            context.cgContext.move(to: polygon.first!)
            for point in polygon[1...] {
                context.cgContext.addLine(to: point)
            }
            
            context.cgContext.setFillColor(CGColor(gray: 1, alpha: 1))
            context.cgContext.fillPath()
        }
        return renderer.image { context in
            draw(in: .init(origin: .zero, size: size), blendMode: .normal, alpha: 1)
            mask.draw(in: .init(origin: .zero, size: size), blendMode: .destinationIn, alpha: 1)
        }
    }
}
