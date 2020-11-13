import UIKit
import TagListView
import Presentr

struct TagChoiceSection {
    let allowsEditing: Bool
    var items: [TagChoice]
    var isDuringEditing = false
}

struct TagChoice {
    let tag: String
    var isChosen: Bool
}

protocol TagsVCDelegate: class {
    func tagsVCDidFinishChoose(_ tagsVC: TagsVC, tagChoice_Sections: [TagChoiceSection])
}

class TagsVC: UIViewController {
    lazy var presentr: Presentr = {
        let tmp = Presentr(presentationType: .popup)
        tmp.transitionType = .crossDissolve
        tmp.dismissTransitionType = .crossDissolve
        tmp.backgroundTap = .dismiss
        return tmp
    }()
        
    weak var delegate: TagsVCDelegate?
    
    private var tagChoice_Sections: [TagChoiceSection]
    
    private lazy var tagsView: UITableView = {
        let tmp = UITableView(frame: .zero, style: .plain)
        tmp.backgroundColor = .secondarySystemBackground
        tmp.separatorStyle = .none
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.register(TagCell.self, forCellReuseIdentifier: TagCell.identifier)
        tmp.register(AddingCell.self, forCellReuseIdentifier: AddingCell.identifier)
        tmp.register(InputingCell.self, forCellReuseIdentifier: InputingCell.identifier)
        tmp.delegate = self
        tmp.dataSource = self
        tmp.delaysContentTouches = false
        tmp.isEditing = true
        tmp.allowsSelectionDuringEditing = true
        return tmp
    }()

    init(tagChoice_Sections: [TagChoiceSection]) {
        self.tagChoice_Sections = tagChoice_Sections
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .secondarySystemBackground
        
        navigationItem.title = title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnTapped))
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.shadowColor = .none
        standardAppearance.backgroundColor = .secondarySystemBackground
        navigationItem.standardAppearance = standardAppearance
        
        view.addSubview(tagsView)
        tagsView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 2).isActive = true
        tagsView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0).isActive = true
        view.trailingAnchor.constraint(equalToSystemSpacingAfter: tagsView.trailingAnchor, multiplier: 0).isActive = true
        tagsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func doneBtnTapped() {
        self.dismiss(animated: true)
        
        delegate?.tagsVCDidFinishChoose(self, tagChoice_Sections: tagChoice_Sections)
    }
}

extension TagsVC: UITableViewDelegate, UITableViewDataSource, InputPerspectiveCellDelegate {
    func cellType(indexPath: IndexPath) -> String {
        let section = tagChoice_Sections[indexPath.section]
        if section.allowsEditing && !section.isDuringEditing && section.items.count == indexPath.row {
            return AddingCell.identifier
        } else if section.allowsEditing && section.isDuringEditing && indexPath.row == section.items.count {
            return InputingCell.identifier
        } else {
            return TagCell.identifier
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tagChoice_Sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = tagChoice_Sections[section]
        return section.items.count + (section.allowsEditing ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cellType(indexPath: indexPath) {
        case AddingCell.identifier:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddingCell.identifier, for: indexPath)
            return cell
        case InputingCell.identifier:
                let cell = tableView.dequeueReusableCell(withIdentifier: InputingCell.identifier, for: indexPath) as! InputingCell
                cell.delegate = self
                cell.textField.placeholder = "input"
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    cell.textField.becomeFirstResponder()
                }
                return cell
        default:
                let cell = tableView.dequeueReusableCell(withIdentifier: TagCell.identifier, for: indexPath)
                let tagChoice = tagChoice_Sections[indexPath.section].items[indexPath.row]
                cell.textLabel!.text = tagChoice.tag
                cell.accessoryType = tagChoice.isChosen ? .checkmark : .none
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = tagChoice_Sections[section]
        switch section.allowsEditing {
        case true:
            return "Condition"
        case false:
            return "Dictionary"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = tagChoice_Sections[indexPath.section]
        
        if section.allowsEditing && !section.isDuringEditing && section.items.count == indexPath.row {
            setDuringInput(to: true, section: indexPath.section)
        } else {
            tagChoice_Sections[indexPath.section].items[indexPath.row].isChosen = !tagChoice_Sections[indexPath.section].items[indexPath.row].isChosen
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        switch editingStyle {
//        case .insert:
//            setDuringInput(to: true)
//        default:
//            fatalError()
//        }
//    }
    
    private func setDuringInput(to: Bool, section: Int) {
        tagChoice_Sections[section].isDuringEditing = to
        tagsView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return cellType(indexPath: indexPath) == AddingCell.identifier ? .insert : .none
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return cellType(indexPath: indexPath) == AddingCell.identifier
    }
    
    internal func inputPerspectiveCellDidEndEditing(_ inputingCell: InputingCell) {
        let indexPath = tagsView.indexPath(for: inputingCell)!
        tagChoice_Sections[indexPath.section].items.append(TagChoice(tag: inputingCell.textField.text!, isChosen: true))
        setDuringInput(to: false, section: indexPath.section)
    }
}

private class TagCell: UITableViewCell {
    static let identifier = "TagCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Self.identifier)
        backgroundColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
