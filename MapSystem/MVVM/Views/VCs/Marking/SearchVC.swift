import UIKit
import MapKit
import FloatingPanel

class SearchVC: UIViewController, PanelContent {
    var prevPanelState:  FloatingPanelState?
    
    var allowsEditing = true
    
    let showBackBtn = false
    
    var panelContentDelegate: PanelContentDelegate!
    
    private lazy var searchSuggestionsController: SearchSuggestionsVC = {
        let tmp = SearchSuggestionsVC()
        tmp.searchDidFinish = {
            self.searchBar.resignFirstResponder()
        }
        return tmp
    }()
    
    lazy var searchBar: UISearchBar = {
        let tmp = UISearchBar()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.searchBarStyle = .minimal
        tmp.isTranslucent = false
        tmp.searchTextField.returnKeyType = .done
        tmp.delegate = self
        return tmp
    }()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vc.view)
        vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        vc.view.topAnchor.constraint(equalToSystemSpacingBelow: searchBar.bottomAnchor, multiplier: 1).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vc.didMove(toParent: self)
    }
    
    func hide(_ vc: UIViewController) {
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }
}

extension SearchVC: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        show(searchSuggestionsController, sender: self)
        searchBar.setShowsCancelButton(true, animated: false)
        UIView.animate(withDuration: 0.25) {
            self.panelContentDelegate?.panel.move(to: .full, animated: false)
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchSuggestionsController.searchUpdater(searchText)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        hide(searchSuggestionsController)
        searchBar.clear()
        searchBar.setShowsCancelButton(false, animated: false)
        UIView.animate(withDuration: 0.25) {
            self.panelContentDelegate?.panel.move(to: .tip, animated: false)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}
