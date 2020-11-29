import UIKit

extension Individual {
    var profile: Profile {
        Profile(name: title ?? _id, image: avatar == nil ? nil : UIImage(data: avatar!))
    }
}
