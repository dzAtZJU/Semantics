import UIKit

extension UIButton {
    convenience init(systemName: String, textStyle: UIFont.TextStyle = .title1, target: Any? = nil, selector: Selector? = nil) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(textStyle: textStyle)), for: .normal)
        if let selector = selector {
            addTarget(target, action: selector, for: .touchUpInside)
        }
    }
    
    convenience init(systemName: String, textStyle: UIFont.TextStyle = .title1, primaryAction: UIAction) {
        self.init(primaryAction: primaryAction)
        translatesAutoresizingMaskIntoConstraints = false
        setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(textStyle: textStyle)), for: .normal)
    }
}
