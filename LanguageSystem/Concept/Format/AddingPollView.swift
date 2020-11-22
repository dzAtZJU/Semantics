import UIKit

class AddingPollView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            update()
        }
    }
    
    lazy var textField: UITextField = {
        let tmp = UITextField()
        tmp.textAlignment = .center
        tmp.placeholder = "Input 对象"
        tmp.delegate = self
        return tmp
    }()
    
    let portionSlider: PortionSlider = {
        let tmp = PortionSlider()
        return tmp
    }()
    
    lazy var sourceView: UISearchBar = {
        let tmp = Adding.createAddingLinkView(returnKeyType: .done)
        tmp.delegate = self
        return tmp
    }()
    
    let stack: UIStackView = {
        let tmp = UIStackView()
        tmp.distribution = .equalSpacing
        tmp.isLayoutMarginsRelativeArrangement = true
        tmp.axis = .vertical
        return tmp
    }()
    
    init(configuration configuration_: AddingPollViewContentConfiguration) {
        configuration = configuration_
        
        super.init(frame: .zero)
        
        addSubview(stack)
        stack.fillToSuperviewMargins()
        stack.addArrangedSubviews([textField, portionSlider, sourceView])
        
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var addingPollViewContentConfiguration: AddingPollViewContentConfiguration {
        configuration as! AddingPollViewContentConfiguration
    }
    
    func update() {}
    
    var isValidate: Bool {
        textField.hasText && sourceView.searchTextField.hasText && portionSlider.portion != nil
    }
    
    func checkCompletion() {
        if isValidate {
            addingPollViewContentConfiguration.completed(textField.text!, portionSlider.portion, URL(string: sourceView.text!)!)
        }
    }
}

extension AddingPollView: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        checkCompletion()
    }
}

extension AddingPollView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkCompletion()
        return true
    }
}

struct AddingPollViewContentConfiguration: UIContentConfiguration {
    func updated(for state: UIConfigurationState) -> AddingPollViewContentConfiguration {
        self
    }
    
    func makeContentView() -> UIView & UIContentView {
        AddingPollView(configuration: self)
    }
    
    let completed: ((String, Int, URL)->())
}

