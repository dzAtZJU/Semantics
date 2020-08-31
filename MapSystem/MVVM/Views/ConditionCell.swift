//
//  ConditionCell.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/9.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import Combine

class ConditionCell: UICollectionViewCell {
    static let identifier = "ConditionCell"
    var indexPath: IndexPath! = nil
    var token: AnyCancellable! = nil
    
    private(set) lazy var label: UILabel = {
        let tmp = UILabel()
        tmp.textColor = .label
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
    private(set) lazy var segmentedControl: UISegmentedControl = {
        let tmp = UISegmentedControl(items: ["Better", "No Worse", "No Matter"])
        tmp.backgroundColor = .systemBackground
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.setTitleTextAttributes([.foregroundColor : UIColor.label], for: .normal)
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(segmentedControl)
        segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        segmentedControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        segmentedControl.removeTarget(nil, action: nil, for: .allEvents)
    }
    
    func cleanForDisappear() {
        if token != nil {
            token.cancel()
            token = nil
        }
    }
}
