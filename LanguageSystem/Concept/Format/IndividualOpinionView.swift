import UIKit

class IndividualOpinionView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            update()
        }
    }
    
    let label: UILabel = {
        let tmp = UILabel()
        tmp.textColor = .lightGray
        tmp.font = .preferredFont(forTextStyle: .title3)
        return tmp
    }()
    
    let switcher = UISwitch()
    
    init(configuration configuration_: IndividualOpinionContentConfiguration) {
        configuration = configuration_
        
        super.init(frame: .zero)
        
        switcher.thumbTintColor = .link
        switcher.tintColor = .lightGray
        switcher.onTintColor = .lightGray
        addSubview(switcher)
        switcher.anchorCenterSuperview()
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var individualOpinionContentConfiguration: IndividualOpinionContentConfiguration {
        configuration as! IndividualOpinionContentConfiguration
    }
    
    func update() {
        let opinion = individualOpinionContentConfiguration.opinion
        label.text = opinion.title
        let opinionData = opinion.opinionData as! Opinion.Individual
        switcher.isOn = opinionData.isAgree
    }
}

struct IndividualOpinionContentConfiguration: UIContentConfiguration {
    func updated(for state: UIConfigurationState) -> IndividualOpinionContentConfiguration {
        self
    }
    
    func makeContentView() -> UIView & UIContentView {
        IndividualOpinionView(configuration: self)
    }
    
    let opinion: Opinion
}

