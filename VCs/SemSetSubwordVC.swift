//
//  SemSetSubwordVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/8.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import SwiftUI
import UIKit

protocol SemSetSubwordVCDelegate: class {
    func upadteSubword(oldText: String, newText: String)
}

class SemSetSubwordVC: UIHostingController<TextOnCircle> {
    
    let delegate: SemSetSubwordVCDelegate
    
    var dynamicItem: UIDynamicItem? = nil
    
    var subwordName: String {
        rootView.editedText
    }
    
    init(text: String, delegate delegate_: SemSetSubwordVCDelegate) {
        
        delegate = delegate_
        super.init(rootView: TextOnCircle(text,
                                          onCommit: { (oldText, newText) in
            delegate_.upadteSubword(oldText: oldText, newText: newText)
        }))
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = nil
    }
}
