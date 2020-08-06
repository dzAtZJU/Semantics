//
//  SearchResultsVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/7.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

protocol SearchResultsVCDelegate {
    func searchResultsVC(_ searchResultsVC: SearchResultsVC, didSelectWord word: Word)
}

class SearchResultsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private static let cellIdentifier = "searchResultCell"

    var delegate: SearchResultsVCDelegate?
    
    var words = [Word]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var tableView: UITableView!
    
    override func loadView() {
        view = UIView()
        
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)
        let word = words[indexPath.row]
        cell.textLabel?.text = word.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.searchResultsVC(self, didSelectWord: words[indexPath.row])
    }
}
