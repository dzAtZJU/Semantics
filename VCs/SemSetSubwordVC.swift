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
    func removeIt(_ semSetSubwordVC: SemSetSubwordVC, text: String)
    
    func upadteSubword(oldText: String, newText: String)
}

class SemSetSubwordVC: UIHostingController<TextOnCircle> {
    
    weak var delegate: SemSetSubwordVCDelegate?
    
    var dynamicItem: UIDynamicItem?
    
    init(text: String) {
        super.init(rootView: TextOnCircle(text, onCommit: {_,_ in }))
        rootView = TextOnCircle(text, onCommit: { (oldText, newText) in
            self.delegate?.upadteSubword(oldText: oldText, newText: newText)
        })
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = nil
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(Self.textOnCircleSwiped))
        swipe.direction = .up
        view.addGestureRecognizer(swipe)
    }
    
    @objc func textOnCircleSwiped() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: -1000)
        }) { _ in
            self.delegate?.removeIt(self, text: self.rootView.editedText)
        }
    }
}
