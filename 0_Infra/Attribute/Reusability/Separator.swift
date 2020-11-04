import UIKit

final class SeparatorSupplementaryView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        separator.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        separator.heightAnchor.constraint(equalToConstant: 2).isActive = true
        separator.backgroundColor = .opaqueSeparator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


