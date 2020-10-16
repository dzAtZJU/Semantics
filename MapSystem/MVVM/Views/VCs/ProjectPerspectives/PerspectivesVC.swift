import UIKit
import TagListView

class PerspectivesVC: UIViewController {
    private lazy var privatePerspectivesView: UITableView = {
        let tmp = UITableView(frame: .zero, style: .plain)
        tmp.backgroundColor = .secondarySystemBackground
        tmp.separatorStyle = .none
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.register(PerspectiveCell.self, forCellReuseIdentifier: PerspectiveCell.identifier)
        tmp.delegate = self
        tmp.dataSource = self
        tmp.delaysContentTouches = false
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PerspectiveCell.identifier, for: indexPath)
        cell.textLabel?.text = "adsadadssad"
        cell.accessoryType = .checkmark
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
