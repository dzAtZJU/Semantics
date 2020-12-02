import CoreGraphics
import UIKit

extension CGGradient {
    static func create(uiColors:[UIColor], locations:[CGFloat]) -> CGGradient {
        return create(cgColors: uiColors.map {$0.cgColor}, locations: locations)
    }
    
    static func create(cgColors:[CGColor], locations:[CGFloat]) -> CGGradient {
        return CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgColors as CFArray, locations: locations)!
    }
}
