import UIKit
import TagListView
import Presentr

struct PerspectiveChoice {
    let perspective: String
    var isChosen: Bool
}

protocol PerspectivesVCDelegate: class {
    func perspectivesVCDidFinishChoose(_ perspectivesVC: PerspectivesVC, perspectiveChoice_List: [PerspectiveChoice])
}

class PerspectivesVC: UIViewController {
    lazy var presentr: Presentr = {
        let tmp = Presentr(presentationType: .popup)
        tmp.transitionType = .crossDissolve
        tmp.dismissTransitionType = .crossDissolve
        tmp.backgroundTap = .dismiss
        return tmp
    }()
        
    weak var delegate: PerspectivesVCDelegate?
    
    private var perspectiveChoice_List: [PerspectiveChoice]
    
    private var isDuringInput = false
    
    init(perspectiveChoice_List perspectiveChoice_List_: [PerspectiveChoice]) {
        perspectiveChoice_List = perspectiveChoice_List_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var privatePerspectivesView: UITableView = {
        let tmp = UITableView(frame: .zero, style: .plain)
        tmp.backgroundColor = .secondarySystemBackground
        tmp.separatorStyle = .none
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.register(PerspectiveCell.self, forCellReuseIdentifier: PerspectiveCell.identifier)
        tmp.register(AddPerspectiveCell.self, forCellReuseIdentifier: AddPerspectiveCell.identifier)
        tmp.register(InputPerspectiveCell.self, forCellReuseIdentifier: InputPerspectiveCell.identifier)
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
        
        navigationItem.title = "Conditions"
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
        
        delegate?.perspectivesVCDidFinishChoose(self, perspectiveChoice_List: perspectiveChoice_List)
    }
}

extension PerspectivesVC: UITableViewDelegate, UITableViewDataSource, InputPerspectiveCellDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        isDuringInput ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return perspectiveChoice_List.count + (isDuringInput ? 1 : 0)
        case 1:
            return 1
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == perspectiveChoice_List.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: InputPerspectiveCell.identifier, for: indexPath) as! InputPerspectiveCell
                cell.delegate = self
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    cell.textField.becomeFirstResponder()
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: PerspectiveCell.identifier, for: indexPath)
                let perspectiveChoice = perspectiveChoice_List[indexPath.row]
                cell.textLabel!.text = perspectiveChoice.perspective
                cell.accessoryType = perspectiveChoice.isChosen ? .checkmark : .none
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddPerspectiveCell.identifier, for: indexPath)
            return cell
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            perspectiveChoice_List[indexPath.row].isChosen = !perspectiveChoice_List[indexPath.row].isChosen
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
            privatePerspectivesView.insertRows(at: [IndexPath(row: perspectiveChoice_List.count, section: 0)], with: .fade)
            privatePerspectivesView.deleteSections([1], with: .fade)
            privatePerspectivesView.endUpdates()
        } else {
            isDuringInput = false
            privatePerspectivesView.beginUpdates()
            privatePerspectivesView.reloadRows(at: [IndexPath(row: perspectiveChoice_List.count-1, section: 0)], with: .fade)
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
    
    fileprivate func inputPerspectiveCellDidEndEditing(_ inputPerspectiveCell: InputPerspectiveCell) {
        perspectiveChoice_List.append(PerspectiveChoice(perspective: inputPerspectiveCell.textField.text!, isChosen: true))
        setDuringInput(to: false)
    }
}

private class PerspectiveCell: UITableViewCell {
    static let identifier = "PerspectiveCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Self.identifier)
        backgroundColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class AddPerspectiveCell: UITableViewCell {
    static let identifier = "AddPerspectiveCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Self.identifier)
        backgroundColor = .secondarySystemBackground
        textLabel?.text = "add condition"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private protocol InputPerspectiveCellDelegate: class {
    func inputPerspectiveCellDidEndEditing(_ inputPerspectiveCell: InputPerspectiveCell)
}

private class InputPerspectiveCell: UITableViewCell, UITextFieldDelegate {
    static let identifier = "InputPerspectiveCell"
    
    var textField: UITextField!
    
    unowned var delegate: InputPerspectiveCellDelegate!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: Self.identifier)
        backgroundColor = .secondarySystemBackground
        
        textField = UITextField()
        textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(textField)
        textField.placeholder = "condition"
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
