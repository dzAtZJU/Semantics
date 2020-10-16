import UIKit
import TagListView

class PerspectivesVC: UIViewController {
    private lazy var privatePerspectivesView: UITableView = {
        let tmp = UITableView(frame: .zero, style: .plain)
        tmp.backgroundColor = .secondarySystemBackground
        tmp.separatorStyle = .none
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.register(PerspectiveCell.self, forCellReuseIdentifier: PerspectiveCell.identifier)
        tmp.register(AddPerspectiveCell.self, forCellReuseIdentifier: AddPerspectiveCell.identifier)
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
    }
}

extension PerspectivesVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 1
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: PerspectiveCell.identifier, for: indexPath)
            cell.textLabel?.text = "adsadadssad"
            cell.accessoryType = .checkmark
            
            return cell
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
            let cell = tableView.cellForRow(at: indexPath)!
            switch cell.accessoryType {
            case .checkmark:
                cell.accessoryType = .none
            case .none:
                cell.accessoryType = .checkmark
            default:
                fatalError()
            }
            tableView.deselectRow(at: indexPath, animated: true)
        case 1:
            break
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return indexPath.section == 1 ? .insert : .none
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
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
