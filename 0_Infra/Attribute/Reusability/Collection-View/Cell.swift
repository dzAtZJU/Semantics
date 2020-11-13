import UIKit

enum HeaderType {
    case Title
    case TitleWithAdding
}

class TitleWithAddingSupplementaryView: TitleSupplementaryView {
    class override var identifier: String {
        "TitleWithAddingSupplementaryView"
    }
    
    lazy var addingBtn = UIButton(systemName: "plus", textStyle: .body, primaryAction: UIAction(handler: {_ in
        self.addingBtnTapped?()
    }))
    
    var addingBtnTapped: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(addingBtn)
        NSLayoutConstraint.activate([
            addingBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            addingBtn.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    
class TitleSupplementaryView: UICollectionReusableView {
    class var identifier: String {
        "TitleSupplementaryView"
    }
    
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

class AddingCell: UITableViewCell {
    static let identifier = "AddingCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Self.identifier)
        backgroundColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol InputPerspectiveCellDelegate: class {
    func inputPerspectiveCellDidEndEditing(_ inputPerspectiveCell: InputingCell)
}

class InputingCell: UITableViewCell, UITextFieldDelegate {
    static let identifier = "InputingCell"
    
    var textField: UITextField!
    
    unowned var delegate: InputPerspectiveCellDelegate!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Self.identifier)
        backgroundColor = .secondarySystemBackground
        
        textField = UITextField()
        textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(textField)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = contentView.bounds.insetBy(dx: textLabel!.x, dy: 0)
        textField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        textField.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField.text != nil && !textField.text!.isEmpty else {
            return false
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate!.inputPerspectiveCellDidEndEditing(self)
    }
}

class ConceptContentView : UIView & UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            update()
        }
    }
    
    private var textField: UITextField?
    
    init(configuration configuration_: ConceptContentConfiguration) {
        configuration = configuration_
        super.init(frame: .zero)
        
        loadTextField()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadTextField() {
        textField = UITextField()
        addSubview(textField!)
        textField!.fillToSuperview()
    }
    
    func update() {
        guard let configuration = configuration as? ConceptContentConfiguration else {
            fatalError()
        }
        
        textField!.placeholder = configuration.placeholder
        textField!.delegate = configuration.textFieldDelegate
        textField!.font = configuration.font
    }
}

struct ConceptContentConfiguration: UIContentConfiguration {
    static func inputing() -> Self {
        ConceptContentConfiguration()
    }
    
    func makeContentView() -> UIView & UIContentView {
        ConceptContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> ConceptContentConfiguration {
        self
    }
    
    var placeholder: String?
    
    var textFieldDelegate: UITextFieldDelegate?
    
    var font = UIFont.preferredFont(forTextStyle: .title2)
}

