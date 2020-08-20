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
    let showBackBtn = false
    var panelContentDelegate: PanelContentDelegate?
    
    lazy var searchSuggestionsController: SearchSuggestionsVC = {
        let tmp = SearchSuggestionsVC()
        tmp.searchDidFinish = {
            self.searchController.isActive = false
            self.panelContentDelegate?.panel.move(to: .half, animated: true)
        }
        return tmp
    }()
    
    private lazy var searchController: UISearchController = {
        let tmp = UISearchController(searchResultsController: searchSuggestionsController)
        tmp.searchResultsUpdater = searchSuggestionsController
        tmp.searchBar.delegate = self
        return tmp
    }()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        view.addSubview(searchController.searchBar)
    }
}

extension SearchVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        panelContentDelegate?.panel.move(to: .full, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.panelContentDelegate?.panel.move(to: .half, animated: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        searchSuggestionsController.search(using: searchRequest)
    }
}

