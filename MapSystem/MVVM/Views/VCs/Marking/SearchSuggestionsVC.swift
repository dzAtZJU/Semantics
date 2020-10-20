//
//  SearchSuggestionsController.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/13.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import MapKit

private let excludeCategories: [MKPointOfInterestCategory] = [.airport, .atm, .bank, .carRental, .evCharger, .fireStation, .gasStation, .hospital, .parking, .pharmacy, .police, .postOffice, .publicTransport]

class SearchSuggestionsVC: UITableViewController {
    lazy var searchUpdater: ((String) -> Void) = {
        self.searchCompleter.queryFragment = $0
    }
    
    var searchDidFinish: (() -> Void)?
    
    private class SuggestionCell: UITableViewCell {
        
        static let reuseID = "SuggestionCell"
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
            contentView.backgroundColor = .systemBackground
            textLabel?.textColor = .systemBlue
            detailTextLabel?.textColor = .systemIndigo
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
        tmp.pointOfInterestFilter = .init(excluding: excludeCategories)
        tmp.resultTypes = [.pointOfInterest, .address, .query]
        tmp.delegate = self
        if let searchRegion = MapSysEnvironment.shared.searchRegion {
            tmp.region = searchRegion
        }
        return tmp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .init(origin: .zero, size: .init(width: 0, height: 1)))
        tableView.backgroundColor = .systemBackground
        tableView.register(SuggestionCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchCompleter.cancel()
        super.viewWillAppear(animated)
    }
}

// MARK: MKLocalSearchCompleterDelegate
extension SearchSuggestionsVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
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
        return searchCompleter.results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)

        let suggestion = searchCompleter.results[indexPath.row]
        cell.textLabel!.setHighlightedText(suggestion.title, ranges: suggestion.titleHighlightRanges)
        cell.detailTextLabel!.setHighlightedText(suggestion.subtitle, ranges: suggestion.subtitleHighlightRanges)
        return cell
    }
}

// MARK: UITableViewDelegate
extension SearchSuggestionsVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let complectorResult = searchCompleter.results[indexPath.row]
        let request = MKLocalSearch.Request(completion: complectorResult)
        search(using: request)
    }
    
    func search(using searchRequest: MKLocalSearch.Request) {
        if let searchRegion = MapSysEnvironment.shared.searchRegion {
            searchRequest.region = searchRegion
        }
        
        searchRequest.resultTypes = .pointOfInterest
        searchRequest.pointOfInterestFilter = .init(excluding: excludeCategories)
        
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
