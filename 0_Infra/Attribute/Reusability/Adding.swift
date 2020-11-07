import UIKit
struct Adding {
    static func createAddingLinkView() -> UISearchBar {
        let tmp = UISearchBar()
        tmp.searchBarStyle = .minimal
        tmp.setImage(UIImage(systemName: "link"), for: .search, state: .normal)
        
        tmp.placeholder = "Input URL"
        return tmp
    }
}
