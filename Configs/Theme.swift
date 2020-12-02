import UIKit

struct Theme {
    static let colors: [UIColor] = {
        [UIColor(named: "p0")!,
        UIColor(named: "p1")!,
        UIColor(named: "p2")!,
        UIColor(named: "p3")!]
    }()
    
    static func color(forProximity proximity: Int) -> [CGColor] {
        guard proximity < 3 else {
            return [colors[3].cgColor, colors[3].cgColor]
        }
        
        return [colors[proximity].cgColor, colors[proximity+1].cgColor]
    }
    
    static let selfAnnotationColor = UIColor.systemTeal
    
    static let annotationColors: [UIColor] = [.systemOrange, .systemIndigo, .systemPink, .systemFill]
}
