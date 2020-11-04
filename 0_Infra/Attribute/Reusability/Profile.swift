import UIKit

struct Profile {
    static func createAvatarView() -> UIImageView {
        let tmp = UIImageView()
        tmp.contentMode = .scaleAspectFill
        let height: CGFloat = 70
        tmp.cornerRadius = height/2
        
        tmp.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tmp.heightAnchor.constraint(equalToConstant: height),
            tmp.widthAnchor.constraint(equalTo: tmp.heightAnchor)
        ])
        
        return tmp
    }
    
    static func createContentSourceView() -> UILabel {
        let tmp = UILabel()
        tmp.allowsDefaultTighteningForTruncation = true
        tmp.font = UIFont.preferredFont(forTextStyle: .body)
        
        tmp.translatesAutoresizingMaskIntoConstraints = false
        
        return tmp
    }
}

class AvatarWithNameView: UIStackView {
    let avatarView = Profile.createAvatarView()
    
    lazy var nameLabel: UILabel = {
        let tmp = UILabel()
        tmp.textAlignment = .center
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        axis = .vertical
        alignment = .center
        addArrangedSubviews([avatarView, nameLabel])
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
