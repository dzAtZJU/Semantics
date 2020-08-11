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
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.setTitleTextAttributes([.foregroundColor : UIColor.label], for: .normal)
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(segmentedControl)
        segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        segmentedControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        layoutAttributes.bounds.size.height = segmentedControl.width + label.intrinsicContentSize.width + 10
//        return layoutAttributes
//    }
}
