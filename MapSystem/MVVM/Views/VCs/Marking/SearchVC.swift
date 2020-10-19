//
//  SearchVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/19.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import MapKit

class SearchVC: UIViewController, PanelContent {
    var panelContentVM: PanelContentVM! = nil
    
    let showBackBtn = false
    var panelContentDelegate: PanelContentDelegate!
    
    private lazy var searchSuggestionsController: SearchSuggestionsVC = {
        let tmp = SearchSuggestionsVC()
        tmp.searchDidFinish = {
            self.searchController.isActive = false
            self.panelContentDelegate?.panel.move(to: .tip, animated: true)
        }
        return tmp
    }()
    
    lazy var searchController: UISearchController = {
        let tmp = UISearchController(searchResultsController: searchSuggestionsController)
        tmp.delegate = self
        tmp.view.backgroundColor = .clear
        
        tmp.searchBar.searchBarStyle = .minimal
        tmp.searchBar.isTranslucent = false
        tmp.searchBar.searchTextField.returnKeyType = .done
        tmp.searchResultsUpdater = searchSuggestionsController
        tmp.searchBar.delegate = self
        return tmp
    }()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        view.addSubview(searchController.searchBar)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

// TOOD: Remove UISearchController since its not compatible with FloatingPanel
extension SearchVC: UISearchBarDelegate, UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        panelContentDelegate?.panel.move(to: .full, animated: true)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        panelContentDelegate?.panel.move(to: .half, animated: true)
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        
        self.view.addSubview(searchController.searchBar)
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchSuggestionsController.searchDidFinish?()
//        let searchRequest = MKLocalSearch.Request()
//        searchRequest.naturalLanguageQuery = searchBar.text
//        searchSuggestionsController.search(using: searchRequest)
    }
}
