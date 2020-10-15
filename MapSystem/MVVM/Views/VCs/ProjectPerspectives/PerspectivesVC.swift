import UIKit
import TagListView

class PerspectivesVC: UIViewController {
    
    private var placePerspectivesView: TagListView = {
        let tmp = TagListView()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.textFont = .preferredFont(forTextStyle: .title3)
        tmp.tagBackgroundColor = .systemGreen
        tmp.marginX = 6
        tmp.marginY = 6
        tmp.alignment = .leading
        tmp.backgroundColor = .systemBackground
        return tmp
    }()
    
    private static let cellIdentifier = "privatePerspectiveCell"
    private lazy var privatePerspectivesView: UITableView = {
        let tmp = UITableView(frame: .zero, style: .plain)
        tmp.separatorStyle = .none
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
        tmp.delegate = self
        tmp.dataSource = self
        return tmp
    }()
    
    override func loadView() {
        view = UIView()
        navigationItem.title = "Conditions"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnTapped))
        
        view.addSubview(placePerspectivesView)
        placePerspectivesView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1).isActive = true
        placePerspectivesView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1).isActive = true
        view.trailingAnchor.constraint(equalToSystemSpacingAfter: placePerspectivesView.trailingAnchor, multiplier: 1).isActive = true
        
        view.addSubview(privatePerspectivesView)
        privatePerspectivesView.topAnchor.constraint(equalToSystemSpacingBelow: placePerspectivesView.bottomAnchor, multiplier: 1).isActive = true
        privatePerspectivesView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0).isActive = true
        view.trailingAnchor.constraint(equalToSystemSpacingAfter: privatePerspectivesView.trailingAnchor, multiplier: 0).isActive = true
        privatePerspectivesView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placePerspectivesView.addTags(["1", "12", "123", "1234", "12345", "123456", "1", "12", "123", "1234", "12345", "123456"])
        placePerspectivesView.tagViews.forEach {
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)
        cell.textLabel?.text = "adsadadssad"
        cell.accessoryType = .checkmark
        return cell
    }
}

extension PerspectivesVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
    }
}
