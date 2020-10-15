//
//  FeedbackVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/14.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class ConditionFeedbackVC: UIViewController {
    class ConditionFeedbackCell: UITableViewCell {
        static let cellIdentifier = "conditionFeedbackCell"
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .default, reuseIdentifier: reuseIdentifier)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private lazy var conditionLabel: UILabel = {
        let tmp = UILabel()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.textColor = .systemBlue
        tmp.font = UIFont.preferredFont(forTextStyle: .title3)
        return tmp
    }()
    
    private lazy var placesTableView: UITableView = {
        let tmp = UITableView(frame: .zero, style: .insetGrouped)
        tmp.backgroundColor = .systemYellow
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.register(UITableViewCell.self, forCellReuseIdentifier: ConditionFeedbackCell.cellIdentifier)
        tmp.dataSource = self
        tmp.delegate = self
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
        view.backgroundColor = .systemYellow
        
        view.addSubview(conditionLabel)
        conditionLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1).isActive = true
        conditionLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2).isActive = true
        conditionLabel.text = conditionFeedbackVM.conditionTitle
        
        view.addSubview(placesTableView)
        placesTableView.topAnchor.constraint(equalToSystemSpacingBelow: conditionLabel.bottomAnchor, multiplier: 0.5).isActive = true
        placesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        placesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        placesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        placesTableView.isEditing = true
    }
}

extension ConditionFeedbackVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        conditionFeedbackVM.levels + 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section != 0, section !=  conditionFeedbackVM.levels + 1 else {
            return 0
        }
        
        return conditionFeedbackVM.count(ofLevel: section-1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConditionFeedbackCell.cellIdentifier)!
        let placeInfo = conditionFeedbackVM.placeInfo(at: .init(level: indexPath.section-1, ordinal: indexPath.row))
        cell.textLabel!.text = placeInfo.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        conditionFeedbackVM.movePlace(at: .init(level: sourceIndexPath.section-1, ordinal: sourceIndexPath.row), to: .init(level: destinationIndexPath.section-1, ordinal: destinationIndexPath.row))
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section != 0 else {
            return false
        }
        
        let placeInfo = conditionFeedbackVM.placeInfo(at: .init(level: indexPath.section-1, ordinal: indexPath.row))
        return placeInfo.isTargetPlace
    }
}

extension ConditionFeedbackVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard proposedDestinationIndexPath.section != sourceIndexPath.section else {
            if proposedDestinationIndexPath.row > sourceIndexPath.row {
                return IndexPath(row: 0, section: sourceIndexPath.section+1)
            } else {
                let destSection = sourceIndexPath.section-1
                let destRow = self.tableView(tableView, numberOfRowsInSection: destSection)
                return IndexPath(row: destRow, section: destSection)
            }
        }
        
        return proposedDestinationIndexPath
    }
    
   func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
}
