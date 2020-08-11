//
//  LabelSupplementaryView.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/9.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class LabelSupplementaryView: UICollectionReusableView  {
    private(set) lazy var label: UILabel = {
        let tmp = UILabel()
        tmp.textColor = .label
        tmp.font = .preferredFont(forTextStyle:.title3)
        tmp.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        label.frame = bounds
        super.layoutSubviews()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutAttributes.bounds.size = label.intrinsicContentSize
        return layoutAttributes
    }
}
