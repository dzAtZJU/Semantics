import UIKit

extension Individual {
    var profile: Profile {
        Profile(name: title ?? _id, image: avatar == nil ? nil : UIImage(data: avatar!))
    }
}

protocol HavingOwner {
    var ownerID: String! {
        get
    }
    
    var allowsEditng: Bool {
        get
    }
}

extension HavingOwner {
    var allowsEditng: Bool {
        ownerID == RealmSpace.userID
    }
}
