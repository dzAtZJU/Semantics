//
//  ConditionBackerCell.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/29.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import Combine

class ConditionBackerCell: UICollectionViewCell {
    var indexPath: IndexPath!
    
    static let identifier = "ConditionBackerCell"
    
    private(set) lazy var label: UILabel = {
        let tmp = UILabel()
        tmp.textColor = .label
        tmp.numberOfLines = 0
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
    private(set) lazy var button: UIButton = {
        let tmp = UIButton(systemName: "hand.thumbsdown.fill")
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(button)
        button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        button.removeTarget(nil, action: nil, for: .allEvents)
    }
}
