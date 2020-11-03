import UIKit
import TagListView
import Presentr

struct TagChoice {
    let tag: String
    var isChosen: Bool
}

protocol TagsVCDelegate: class {
    func tagsVCDidFinishChoose(_ tagsVC: TagsVC, tagChoice_List: [TagChoice])
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
    
    private var tagChoice_List: [TagChoice]
    
    private var isDuringInput = false
    
    private let inputingCellPlaceholder: String
    
    private let enableAdding: Bool
    
    init(tagChoice_List tagChoice_List_: [TagChoice], title title_: String, inputingCellPlaceholder inputingCellPlaceholder_: String, enableAdding enableAdding_: Bool) {
        tagChoice_List = tagChoice_List_
        inputingCellPlaceholder = inputingCellPlaceholder_
        enableAdding = enableAdding_
        super.init(nibName: nil, bundle: nil)
        title = title_
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var privatePerspectivesView: UITableView = {
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
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .secondarySystemBackground
        
        navigationItem.title = title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnTapped))
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.shadowColor = .none
        standardAppearance.backgroundColor = .secondarySystemBackground
        navigationItem.standardAppearance = standardAppearance
        
        view.addSubview(privatePerspectivesView)
        privatePerspectivesView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 2).isActive = true
        privatePerspectivesView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0).isActive = true
        view.trailingAnchor.constraint(equalToSystemSpacingAfter: privatePerspectivesView.trailingAnchor, multiplier: 0).isActive = true
        privatePerspectivesView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func doneBtnTapped() {
        self.dismiss(animated: true)
        
        delegate?.tagsVCDidFinishChoose(self, tagChoice_List: tagChoice_List)
    }
}

extension TagsVC: UITableViewDelegate, UITableViewDataSource, InputPerspectiveCellDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if enableAdding {
            return isDuringInput ? 1 : 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return tagChoice_List.count + (isDuringInput ? 1 : 0)
        case 1:
            return 1
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == tagChoice_List.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: InputingCell.identifier, for: indexPath) as! InputingCell
                cell.delegate = self
                cell.textField.placeholder = inputingCellPlaceholder
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    cell.textField.becomeFirstResponder()
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TagCell.identifier, for: indexPath)
                let perspectiveChoice = tagChoice_List[indexPath.row]
                cell.textLabel!.text = perspectiveChoice.tag
                cell.accessoryType = perspectiveChoice.isChosen ? .checkmark : .none
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddingCell.identifier, for: indexPath)
            return cell
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            tagChoice_List[indexPath.row].isChosen = !tagChoice_List[indexPath.row].isChosen
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case 1:
            setDuringInput(to: true)
        default:
            fatalError()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert:
            setDuringInput(to: true)
        default:
            fatalError()
        }
    }
    
    private func setDuringInput(to: Bool) {
        if to {
            isDuringInput = true
            privatePerspectivesView.beginUpdates()
            privatePerspectivesView.insertRows(at: [IndexPath(row: tagChoice_List.count, section: 0)], with: .fade)
            privatePerspectivesView.deleteSections([1], with: .fade)
            privatePerspectivesView.endUpdates()
        } else {
            isDuringInput = false
            privatePerspectivesView.beginUpdates()
            privatePerspectivesView.reloadRows(at: [IndexPath(row: tagChoice_List.count-1, section: 0)], with: .fade)
            privatePerspectivesView.insertSections([1], with: .fade)
            privatePerspectivesView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
            privatePerspectivesView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return indexPath.section == 1 ? .insert : .none
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    fileprivate func inputPerspectiveCellDidEndEditing(_ inputPerspectiveCell: InputingCell) {
        tagChoice_List.append(TagChoice(tag: inputPerspectiveCell.textField.text!, isChosen: true))
        setDuringInput(to: false)
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

private class AddingCell: UITableViewCell {
    static let identifier = "AddingCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Self.identifier)
        backgroundColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private protocol InputPerspectiveCellDelegate: class {
    func inputPerspectiveCellDidEndEditing(_ inputPerspectiveCell: InputingCell)
}

private class InputingCell: UITableViewCell, UITextFieldDelegate {
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
