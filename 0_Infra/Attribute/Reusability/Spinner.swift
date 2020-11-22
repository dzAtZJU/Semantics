import NVActivityIndicatorView
import UIKit

struct Spinner {
    static func create() -> NVActivityIndicatorView {
        let tmp = NVActivityIndicatorView(frame: .zero, type: .ballGridBeat, color: .systemFill, padding: .none)
        tmp.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tmp.widthAnchor.constraint(equalToConstant: 50),
            tmp.heightAnchor.constraint(equalTo: tmp.widthAnchor, multiplier: 1)
        ])
        return tmp
    }
}
