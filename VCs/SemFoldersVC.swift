//
//  SemFoldersVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/6.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class SemFoldersVC: UIViewController {
    private static let cellIdentifier = "folderCell"
    
    private var tableView: UITableView!
    
    override func loadView() {
        view = UIView()
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
        view.addSubview(tableView)
        
        navigationItem.title = "Folders"
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
}

extension SemFoldersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        if indexPath.row == 0 {
            cell.imageView?.image = UIImage(systemName: "folder.fill")
            cell.textLabel?.text = "Folder"
        } else if indexPath.row == 1 {
            cell.imageView?.image = UIImage(systemName: "archivebox.fill")
            cell.textLabel?.text = "Archive"
        } else {
            fatalError()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == 0 {
////            let tab = UITabBarController()
////            tab.viewControllers = [SemSetsVC(isArchive: false), WordsGraphVC()]
//            show(SemSetsVC(isArchive: false, proximity: 5), sender: self)
//        } else if indexPath.row == 1 {
//            show(SemSetsVC(isArchive: true, proximity: 5), sender: self)
//        } else {
//            fatalError()
//        }
    }
}
