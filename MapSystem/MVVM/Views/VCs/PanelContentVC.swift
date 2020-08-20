//
//  PanelContentVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/12.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import MapKit
import FloatingPanel

protocol PanelContent: UIViewController {
    var panelContentDelegate: PanelContentDelegate? { get set }
    
    var showBackBtn: Bool { get }
    
    var topInset: CGFloat { get }
}

extension PanelContent{
    var topInset: CGFloat {
        get {
            0
        }
    }
}


protocol PanelContentDelegate {
    var panel: FloatingPanelController {
        get
    }
}

class PanelContentVC: UIViewController {
    var initialVC: UIViewController?
    var currentVC: UIViewController?
    init(initialVC initialVC_: UIViewController) {
        initialVC = initialVC_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var backBtn: UIButton = UIButton(systemName: "multiply.circle.fill", textStyle: .title2, target: self, selector: #selector(backBtnTapped))
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        view.addSubview(backBtn)
        view.trailingAnchor.constraint(equalToSystemSpacingAfter: backBtn.trailingAnchor, multiplier: 2).isActive = true
        backBtn.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 2).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialVC != nil {
            show(initialVC!, sender: nil)
            initialVC = nil
        }
    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        guard let vc = vc as? PanelContent else {
            fatalError()
        }
        
        addChild(vc)
        vc.view.frame = view.bounds.inset(by: .init(top: vc.topInset ?? 0, left: 0, bottom: 0, right: 0))
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.view.transform = .init(translationX: 0, y: view.height)
        view.addSubview(vc.view)
        view.addSubview(backBtn)
        UIView.animate(withDuration: 0.25, animations: {
            vc.view.transform = .identity
            self.backBtn.isHidden = !vc.showBackBtn
        }) { _ in
            vc.didMove(toParent: self)
        }
    }
    

    func hideTop() {
        guard children.count >= 2, let vc = children.last as? PanelContent else {
            return
        }
        
        var vcWillShow: PanelContent?
        if case let suffix2 = children.suffix(2), suffix2.count == 2 {
            vcWillShow = suffix2.first as? PanelContent
        }
        
        vc.willMove(toParent: nil)
        UIView.animate(withDuration: 0.25, animations: {
            vc.view.transform = .init(translationX: 0, y: self.view.height)
            if let vcWillShow = vcWillShow {
                self.backBtn.isHidden = !vcWillShow.showBackBtn
            }
        }) { _ in
            vc.view.removeFromSuperview()
            vc.view.transform = .identity
            vc.removeFromParent()
        }
    }
}

// MARK: Interaction
extension PanelContentVC {
    @objc private func backBtnTapped() {
        hideTop()
    }
}

extension PanelContentVC: FloatingPanelControllerDelegate{
}
