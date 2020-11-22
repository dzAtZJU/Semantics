import UIKit
struct Adding {
    static func createAddingLinkView(returnKeyType: UIReturnKeyType) -> UISearchBar {
        let tmp = UISearchBar()
        tmp.searchBarStyle = .minimal
        tmp.setImage(UIImage(systemName: "link"), for: .search, state: .normal)
        tmp.placeholder = "Input URL"
        tmp.returnKeyType = returnKeyType
        return tmp
    }
}
