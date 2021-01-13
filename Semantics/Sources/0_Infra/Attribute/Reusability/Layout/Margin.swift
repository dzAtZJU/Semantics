import UIKit

struct Margin {
    static let defaultValue: CGFloat = 8
}

extension NSDirectionalEdgeInsets {
    init(inset: CGFloat) {
        self.init(top: inset, leading: inset, bottom: inset, trailing: inset)
    }
}
