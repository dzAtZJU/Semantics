//
//  FloatingContainerVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/2.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import SwifterSwift

class FloatContainerVC: UIViewController {
    
    private var floatButton: UIButton!
    
    private var floatableVC: UIViewController! {
        didSet {
            isFloating = false
        }
    }
    
    private var isFloating = false
    
    private let rootVC: UIViewController
    init(rootVC rootVC_: UIViewController) {
        rootVC = rootVC_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        addChild(rootVC)
        view.addSubview(rootVC.view)
        rootVC.didMove(toParent: self)
    }
    
    override func viewDidLayoutSubviews() {
        rootVC.view.frame = view.bounds
        
        guard floatableVC != nil else {
            return
        }
        
        layoutFloatableVC(to: isFloating)
    }
    
    func setVC(_ vc: UIViewController) {
        guard floatableVC == nil else {
            fatalError()
        }
        
        floatableVC = vc

        addChild(vc)
        UIView.transition(with: view, duration: 0.5, options: .transitionFlipFromTop, animations: {
            self.view.addSubview(vc.view)
        }) { _ in
            vc.didMove(toParent: self)
            self.floatButton = UIButton(systemName: "smallcircle.circle")
            self.floatButton.addTarget(self, action: #selector(self.floatButtonTapped), for: .touchUpInside)
            UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
                self.view.addSubview(self.floatButton)
                self.floatButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
                self.floatButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
            })
        }
    }
    
    func removeVC() {
        guard isFloating else {
            return
        }
        
        isFloating = false
        floatableVC.willMove(toParent: nil)
        UIView.transition(with: view, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.floatableVC.view.removeFromSuperview()
            self.floatButton.removeFromSuperview()
        }) { _ in
            self.floatableVC.removeFromParent()
            self.floatableVC = nil
            self.floatButton = nil
        }
    }
    
    private func layoutFloatableVC(to isFloating: Bool) {
        let floatableVCView = floatableVC.view!
        if isFloating {
            floatableVCView.size = .init(width: 100, height: 100)
            floatableVCView.frame.origin = self.view.bounds.inset(by: self.view.safeAreaInsets).bottomLeft - CGPoint(x: 0, y: 100)
        } else {
            floatableVCView.frame = view.bounds
        }
    }
}

// MARK: Interaction
extension FloatContainerVC {
    @objc private func floatButtonTapped() {
        toggleFloat()
    }
    
    private func toggleFloat() {
        isFloating = !isFloating
        
        UIView.animate(withDuration: 0.25, animations: {
            self.floatableVC.view.cornerRadius = self.isFloating ? 50 : 0
            self.layoutFloatableVC(to: self.isFloating)
        }) { _ in
            if self.isFloating {
                let pan = UIPanGestureRecognizer(target: self, action: #selector(self.flotaPanned))
                self.floatableVC.view.addGestureRecognizer(pan)
            } else {
                self.floatableVC.view.removeGestureRecognizers()
            }
        }
    }
    
    @objc private func flotaPanned(sender: UIPanGestureRecognizer) {
        let floatableVCView = floatableVC.view!
        floatableVCView.center += sender.translation(in: floatableVCView.superview)
        sender.setTranslation(.zero, in: floatableVCView.superview)
        let centerInWindow = floatableVCView.superview!.convert(floatableVCView.center, to: nil)
        NotificationCenter.default.post(name: .floatMoved, object: Notification.FloatMoved(center: centerInWindow))
    }
}
