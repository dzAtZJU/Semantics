import UIKit

extension UIView {
    func fillToSuperviewMargins() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview!.layoutMarginsGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview!.layoutMarginsGuide.trailingAnchor),
            topAnchor.constraint(equalTo: superview!.layoutMarginsGuide.topAnchor),
            bottomAnchor.constraint(equalTo: superview!.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    func anchorTopLeading() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview!.layoutMarginsGuide.leadingAnchor),
            topAnchor.constraint(equalTo: superview!.layoutMarginsGuide.topAnchor)
        ])
    }
    
    func anchorTopTrailing() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: superview!.layoutMarginsGuide.trailingAnchor),
            topAnchor.constraint(equalTo: superview!.layoutMarginsGuide.topAnchor)
        ])
    }
    
    func anchorBottomCenter() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview!.centerXAnchor),
            bottomAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
