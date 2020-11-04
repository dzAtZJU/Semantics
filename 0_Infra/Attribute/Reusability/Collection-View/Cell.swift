import UIKit

class TitleSupplementaryView: UICollectionReusableView {
    static let identifier = "TitleSupplementaryView"
    
    let label: UILabel = {
        let tmp = UILabel()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.adjustsFontForContentSizeCategory = true
        tmp.font = UIFont.preferredFont(forTextStyle: .callout)
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let size = label.intrinsicContentSize
        layoutAttributes.bounds.size.height = size.height + 20
        return layoutAttributes
    }
}

class ImageWithTitleCell: UICollectionViewCell {
    static let identifier = "ImageCell"
    
    let titleLabel: UILabel = {
        let tmp = UILabel()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.numberOfLines = 0
        tmp.font = UIFont.preferredFont(forTextStyle: .headline)
        return tmp
    }()
    
    let subtitleLabel: UILabel = {
        let tmp = UILabel()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.numberOfLines = 0
        tmp.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return tmp
    }()
    
    let imageView: UIImageView = {
        let tmp = UIImageView()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.cornerRadius = 4
        tmp.contentMode = .scaleAspectFill
        tmp.alpha = 0.8
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor),
            subtitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: subtitleLabel.bottomAnchor, multiplier: 1),
            subtitleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.7)
            ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
