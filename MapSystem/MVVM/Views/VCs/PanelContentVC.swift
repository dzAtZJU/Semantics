//
//  PanelContentVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/12.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import MapKit
import FloatingPanel

protocol PanelContentVCDelegate {
    func panelContentVC(_ panelContentVC: PanelContentVC, searchDidFinishiWithResponse response: MKLocalSearch.Response)
    
    func panelContentVCShouldStartFeedback(_ panelContentVC: PanelContentVC)
}

class PanelContentVC: UIViewController {
    lazy var searchSuggestionsController: SearchSuggestionsController = {
        let tmp = SearchSuggestionsController()
        tmp.tableView.delegate = self
        return tmp
    }()
    
    private lazy var searchController: UISearchController = {
        let tmp = UISearchController(searchResultsController: searchSuggestionsController)
        tmp.searchResultsUpdater = searchSuggestionsController
        tmp.searchBar.delegate = self
        return tmp
    }()
    
    private lazy var feedbackBtn: UIButton = {
        let tmp = UIButton(type: .roundedRect)
        tmp.cornerRadius = 10
        tmp.setTitleForAllStates("Feedback")
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.addTarget(self, action: #selector(feedbackBtnTapped), for: .touchUpInside)
        tmp.backgroundColor = .systemBlue
        tmp.tintColor = .white
        tmp.widthAnchor.constraint(equalToConstant: 150).isActive = true
        tmp.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tmp
    }()
    
    var delegate: PanelContentVCDelegate?
    
    private var localSearch: MKLocalSearch?
    private var localSearchPlaces: [MKMapItem]?
    private var locaSearchBoundingRegion: MKCoordinateRegion?
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .yellow
        
        view.addSubview(searchController.searchBar)
        
        view.addSubview(feedbackBtn)
        feedbackBtn.topAnchor.constraint(equalToSystemSpacingBelow: searchController.searchBar.bottomAnchor, multiplier: 2).isActive = true
        feedbackBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    func updateUserLocation(_ location: CLLocationCoordinate2D) {
        searchSuggestionsController.updateUserLocation(location)
    }
}

extension PanelContentVC {
    @objc private func feedbackBtnTapped() {
        delegate?.panelContentVCShouldStartFeedback(self)
    }
}

extension PanelContentVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard let fpc = parent as? FloatingPanelController else {
            return
        }
        fpc.move(to: .full, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let fpc = parent as? FloatingPanelController else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                fpc.move(to: .half, animated: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        search(using: searchRequest)
    }
}

extension PanelContentVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let complectorResult = searchSuggestionsController.completerResults![indexPath.row]
        let request = MKLocalSearch.Request(completion: complectorResult)
        search(using: request)
    }
    
    private func search(using searchRequest: MKLocalSearch.Request) {
        searchController.isActive = false
        if let parent = parent as? FloatingPanelController {
            parent.move(to: .half, animated: true)
        }
        
        // Confine the map search area to an area around the user's current location.
//        searchRequest.region = searchSuggestionsController.searchCompleter.region
        searchRequest.resultTypes = .pointOfInterest
        searchRequest.pointOfInterestFilter = .init(including: [.cafe, .restaurant])
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch!.start { [unowned self] (response, error) in
            guard error == nil, let response = response else {
                fatalError()
            }
            
            self.delegate?.panelContentVC(self, searchDidFinishiWithResponse: response)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.superview == searchSuggestionsController.view {
            searchController.searchBar.resignFirstResponder()
        }
    }
}
