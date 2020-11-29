import UIKit

struct Profile {
    static func createAvatarView(width: CGFloat) -> UIImageView {
        let tmp = UIImageView()
        tmp.contentMode = .scaleAspectFill
        tmp.cornerRadius = width/2
        
        tmp.backgroundColor = .secondarySystemFill
        tmp.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tmp.heightAnchor.constraint(equalToConstant: width),
            tmp.widthAnchor.constraint(equalTo: tmp.heightAnchor)
        ])
        
        return tmp
    }
    
    let name: String
    let image: UIImage?
    
    init(name: String, image: UIImage?) {
        self.name = name
        self.image = image
    }
    
    init(name: String, imageData: Data?) {
        let image = imageData != nil ? UIImage(data: imageData!) : nil
        self.init(name: name, image: image)
    }
}

class AvatarWithNameView: UIStackView {
    let avatarView: UIImageView
    
    lazy var nameLabel: UILabel = {
        let tmp = UILabel()
        tmp.font = .preferredFont(forTextStyle: .title3)
        tmp.textAlignment = .center
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
    init(axis: NSLayoutConstraint.Axis, width: CGFloat) {
        avatarView = Profile.createAvatarView(width: width)
        
        super.init(frame: .zero)
        self.axis = axis
        spacing = Margin.defaultValue
        alignment = .center
        addArrangedSubviews([avatarView, nameLabel])
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
