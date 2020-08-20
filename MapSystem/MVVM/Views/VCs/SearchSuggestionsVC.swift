//
//  SearchSuggestionsController.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/13.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import MapKit

class SearchSuggestionsVC: UITableViewController {
    var searchDidFinish: (() -> Void)?
    
    private class SuggestionCell: UITableViewCell {
        
        static let reuseID = "SuggestionCell"
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    private var localSearch: MKLocalSearch?
    private var localSearchPlaces: [MKMapItem]?
    private var locaSearchBoundingRegion: MKCoordinateRegion?
    
    private static let cellIdentifier = "cellIdentifier"
    
    private(set) lazy var searchCompleter: MKLocalSearchCompleter = {
        let tmp = MKLocalSearchCompleter()
        tmp.pointOfInterestFilter = .init(including: [.cafe, .restaurant])
        tmp.resultTypes = [.pointOfInterest]
        tmp.delegate = self
        
        
        return tmp
    }()
    
    private(set) var completerResults: [MKLocalSearchCompletion]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SuggestionCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchCompleter.cancel()
        super.viewWillAppear(animated)
    }
}

// MARK: UISearchResultsUpdating
extension SearchSuggestionsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchCompleter.queryFragment = searchController.searchBar.text ?? ""
//        print("queryFragment: \(searchCompleter.queryFragment)")
    }
}

// MARK: MKLocalSearchCompleterDelegate
extension SearchSuggestionsVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerResults = completer.results
        tableView.reloadData()
    }
    
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if let error = error as NSError? {
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription). The query fragment is: \"\(completer.queryFragment)\"")
        }
    }
}

// MARK: UITableViewDataSource
extension SearchSuggestionsVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completerResults?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)

        let suggestion = completerResults![indexPath.row]
        cell.textLabel!.setHighlightedText(suggestion.title, ranges: suggestion.titleHighlightRanges)
        cell.detailTextLabel!.setHighlightedText(suggestion.subtitle, ranges: suggestion.subtitleHighlightRanges)
        return cell
    }
}

// MARK: UITableViewDelegate
extension SearchSuggestionsVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let complectorResult = completerResults![indexPath.row]
        let request = MKLocalSearch.Request(completion: complectorResult)
        search(using: request)
    }
    
    func search(using searchRequest: MKLocalSearch.Request) {
        if let searchRegion = MapSysEnvironment.shared.searchRegion {
            searchRequest.region = searchRegion
        }
        
        searchRequest.resultTypes = .pointOfInterest
        searchRequest.pointOfInterestFilter = .init(including: [.cafe, .restaurant])
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch!.start { [unowned self] (response, error) in
            guard error == nil, let response = response else {
                fatalError()
            }
            
            self.searchDidFinish?()
            NotificationCenter.default.post(name: NSNotification.Name.searchFinished, object: response)
        }
    }
}
