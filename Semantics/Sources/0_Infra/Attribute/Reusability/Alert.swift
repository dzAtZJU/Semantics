import SPAlert
import UIKit

extension SPAlert {
    static func present(title: String, message: String? = nil, image: UIImage?) {
        if let image = image {
            let imgView = UIImageView(image: image)
            imgView.contentMode = .scaleAspectFill
            present(title: title, message: message, icon: imgView)
        } else {
            present(title: title, message: message, preset: SPAlertPreset.star)
        }
    }
    
    private static func present(title: String, message: String? = nil, icon: UIView) {
        let alertView = SPAlertView(title: title, message: message, icon: icon)
        alertView.present()
    }
}
