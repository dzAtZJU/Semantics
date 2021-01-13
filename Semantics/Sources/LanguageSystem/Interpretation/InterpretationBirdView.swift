import UIKit

class InterpretationBirdView: UIView {
    lazy var avatarWithNameView: AvatarWithNameView = {
        let tmp = AvatarWithNameView(axis: .vertical, width: 60)
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
    lazy var contentSourcesView: UIStackView = {
        let contentSources = (0..<contentSourcesCountLimit).map { (Int) -> UILabel in
            let tmp = UILabel()
            tmp.allowsDefaultTighteningForTruncation = true
            tmp.font = UIFont.preferredFont(forTextStyle: .body)
            
            tmp.translatesAutoresizingMaskIntoConstraints = false
            
            return tmp
        }
        let stack = UIStackView(arrangedSubviews: contentSources, axis: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var moreInteractionsButton: UIButton = {
        let tmp = UIButton(systemName: "ellipsis", textStyle: .title3, target: self, selector: #selector(moreInteractionsButtonTapped))
        return tmp
    }()
    
    private let contentSourcesCountLimit = 4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(avatarWithNameView)
        NSLayoutConstraint.activate([
            avatarWithNameView.trailingAnchor.constraint(equalTo: trailingAnchor),
            avatarWithNameView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        addSubview(contentSourcesView)
        NSLayoutConstraint.activate([
            contentSourcesView.topAnchor.constraint(equalTo: topAnchor),
            contentSourcesView.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarWithNameView.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: contentSourcesView.trailingAnchor, multiplier: 2)
        ])
        
        addSubview(moreInteractionsButton)
        NSLayoutConstraint.activate([
            moreInteractionsButton.topAnchor.constraint(equalToSystemSpacingBelow: avatarWithNameView.bottomAnchor, multiplier: 1),
            moreInteractionsButton.centerXAnchor.constraint(equalTo: avatarWithNameView.centerXAnchor),
            moreInteractionsButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContentSources(_ contentSources: [String]) {
        for i in 0..<min(contentSources.count, contentSourcesCountLimit) {
            (contentSourcesView.subviews[i] as! UILabel).text = contentSources[i]
        }
    }
    
    @objc func moreInteractionsButtonTapped() {
        
    }
}
