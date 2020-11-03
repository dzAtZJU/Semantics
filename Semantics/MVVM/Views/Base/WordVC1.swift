//
//  WordVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/7.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import UIKit
import SwiftUI
import CoreData
import Kingfisher
import SwifterSwift
import CloudKit

class WordVC1: UIViewController {
    // MARK: UI Property
    private static let fallingDuration = 0.4
    
    private static let fadeInDuration = 2.0
    
    private lazy var background: UIImageView = {
        let tmp = UIImageView()
        tmp.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tmp.contentMode = .scaleAspectFill
        
        let xMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotionEffect.minimumRelativeValue = -10
        xMotionEffect.maximumRelativeValue = 10
        let yMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yMotionEffect.minimumRelativeValue = -10
        yMotionEffect.maximumRelativeValue = 10
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotionEffect, yMotionEffect]
        tmp.addMotionEffect(group)
        return tmp
    }()
    
    private lazy var nameField: SemTextView = {
        let tmp = SemTextView(frame: .zero)
        tmp.text = word.name
        tmp.font = UIFont.preferredFont(forTextStyle: .title3)
        
        tmp.backgroundColor = .systemFill
        tmp.textColor = .label
        tmp.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        return tmp
    }()
    
    private lazy var animator = UIDynamicAnimator(referenceView: view)
    private lazy var gravity = UIGravityBehavior()
    private lazy var collision = UICollisionBehavior()
    private var dynamicBahav: UIDynamicItemBehavior = {
        let r = UIDynamicItemBehavior()
        r.allowsRotation = false
        return r
    }()
    
    // MARK: Model Property
    private lazy var rootView2VC = [UIView: SubwordVC]()
    
    // MARK: Initialzier
    private(set) var word: WordVM
    
    init(word word_: WordVM) {
        word = word_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: LifeCycle
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        view.addSubview(background)
        view.addSubview(nameField)
    }
    
    override func viewDidLoad() {
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        animator.addBehavior(dynamicBahav)
        
        if word.subWords.capacity > 0 {
            var index = 0
            Timer.scheduledTimer(withTimeInterval: Self.fallingDuration, repeats: true) { timer in
                self.addSubwordVC(SubwordVC(text: self.word.subWords[index]))
                index += 1
                if index == self.word.subWords.endIndex {
                    timer.invalidate()
                }
            }.fire()
        }
        
        nameField.frame = .init(origin: .zero, size: CGSize(width: view.bounds.width, height: 50))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        nameField.frame = .init(origin: CGPoint(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top), size: CGSize(width: view.bounds.width, height: 50))
        collision.setTranslatesReferenceBoundsIntoBoundary(with: UIEdgeInsets(top: -1000, left: 0, bottom: view.safeAreaInsets.bottom, right: 0))
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        animator.removeAllBehaviors()
        coordinator.animate(alongsideTransition: { (context) in
            self.rootView2VC.keys.forEach {
                $0.center.y = size.height + 90
                $0.alpha = 0
            }
        }, completion: { (context) in
            self.animator.addBehavior(self.gravity)
            self.animator.addBehavior(self.collision)
            self.animator.addBehavior(self.dynamicBahav)
            var index = self.gravity.items.count - 1
            Timer.scheduledTimer(withTimeInterval: Self.fallingDuration, repeats: true) { (timer) in
                guard index >= 0 else {
                    timer.invalidate()
                    return
                }
                
                let item = self.gravity.items[index] as! UIView
                item.center = CGPoint(x: Int.random(in: 90...Int(size.width-90)), y: -180)
                self.animator.updateItem(usingCurrentState: item)
                UIView.animate(withDuration: Self.fadeInDuration) {
                    item.alpha = 1
                }
                
                index -= 1
            }.fire()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CoreDataSpace.shared.saveContext()
    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        guard let subwordVC = vc as? SubwordVC else {
            super.show(vc, sender: sender)
            return
        }
        
        //
        addChild(subwordVC)
        subwordVC.view.frame = .init(origin: .init(x: Int.random(in: 75...300), y: -150), size: .init(width: 150, height: 150))
        view.addSubview(subwordVC.view)
        subwordVC.didMove(toParent: self)
        
        //
        subwordVC.view.alpha = 0
        UIView.animate(withDuration: Self.fadeInDuration) {
            subwordVC.view.alpha = 1
        }
        
        //
        subwordVC.dynamicItem = subwordVC.view
        gravity.addItem(subwordVC.view)
        collision.addItem(subwordVC.view)
        dynamicBahav.addItem(subwordVC.view)
    }
    
    private func addSubwordVC(_ wordVC: SubwordVC) {
           rootView2VC[wordVC.view] = wordVC
           show(wordVC, sender: self)
    }
}
