//
//  FeedbackVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/14.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class ConditionFeedbackVC: UIViewController {
    private static let cellIdentifier = "cellIdentifier"
    
    private lazy var conditionLabel: UILabel = {
        let tmp = UILabel()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.font = UIFont.preferredFont(forTextStyle: .title3)
        return tmp
    }()
    
    private lazy var placesTableView: UITableView = {
        let tmp = UITableView(frame: .zero, style: .insetGrouped)
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
        tmp.dataSource = self
        return tmp
    }()
    
    let conditionFeedbackVM: ConditionFeedbackVM
    init(conditionFeedbackVM conditionFeedbackVM_: ConditionFeedbackVM) {
        conditionFeedbackVM = conditionFeedbackVM_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(conditionLabel)
        conditionLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1).isActive = true
        conditionLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2).isActive = true
        conditionLabel.text = conditionFeedbackVM.conditionTitle
        
        view.addSubview(placesTableView)
        placesTableView.topAnchor.constraint(equalToSystemSpacingBelow: conditionLabel.bottomAnchor, multiplier: 0.5).isActive = true
        placesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        placesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        placesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension ConditionFeedbackVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        conditionFeedbackVM.levels
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conditionFeedbackVM.count(ofLevel: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier)!
        
        cell.textLabel!.text = conditionFeedbackVM.placeTitle(atLevel: indexPath.section, ordinal: indexPath.row)
        return cell
    }
}

extension ConditionFeedbackVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
}
