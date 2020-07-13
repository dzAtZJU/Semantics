//
//  SemSetVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/7.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import UIKit
import SwiftUI
import CoreData
import Kingfisher

@objc
protocol SemSetVCDelegate {
    @objc optional func back()
}

class SemSetVC: UIViewController {
    private static let fallingDuration = 0.3
    private static let fadeInDuration = 2.5
    
    lazy var background: UIImageView = {
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
    
    lazy var nameField: SemTextView = {
        let tmp = SemTextView(frame: .zero)
        tmp.text = word.name?.appending(neighborWords: Set(word.neighborWordsName))
        tmp.font = UIFont.preferredFont(forTextStyle: .title3)
        
        tmp.backgroundColor = .systemFill
        tmp.textColor = .label
        tmp.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        tmp.delegate = self
        return tmp
    }()
    
    lazy var addButton: UIButton = {
        let tmp = UIButton(type: .contactAdd)
        tmp.addTarget(self, action: #selector(Self.addSubWord), for: .touchUpInside)
        tmp.alpha = 0.7
        return tmp
    }()
    
    private lazy var animator = UIDynamicAnimator(referenceView: view)
    private lazy var gravity = UIGravityBehavior()
    private lazy var collision = UICollisionBehavior()
    private var dynamic: UIDynamicItemBehavior!
    private var attatchment: UIAttachmentBehavior!
    
    var delegate: SemSetVCDelegate?
    
    private var isFirstEditing = true
    
    private var word: Word!
    
    private var task: URLSessionDataTask?
    
    lazy private var rootView2VC = [UIView: SemSetSubwordVC]()
    
    lazy private var runningAnimators = [UIViewPropertyAnimator]()
    
    init(word word_: Word?, title: String?, proximity: Int = 5) {
        super.init(nibName: nil, bundle: nil)
        
        if let word_ = word_ {
            word = word_
        } else if let title = title {
            let request: NSFetchRequest<Word> = Word.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", title)
            let resutls = try! managedObjectContext.fetch(request)
            word = resutls.first
        }
        
        if word == nil {
            word = Word(context: managedObjectContext)
            word.proximity = Int16(proximity)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        task?.cancel()
    }
    
    // MARK: Override
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        view.addSubview(background)
        view.addSubview(nameField)
        view.addSubview(addButton)
    }
    
    override func viewDidLoad() {
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        
        if word.subWords != nil, word.subWords!.capacity > 0 {
            var index = 0
            Timer.scheduledTimer(withTimeInterval: Self.fallingDuration, repeats: true) { timer in
                self.addSubwordVC(SemSetSubwordVC(text: self.word.subWords![index], delegate: self))
                index += 1
                if index == self.word.subWords!.endIndex {
                    timer.invalidate()
                }
            }
        }
        
        nameField.frame = .init(origin: .zero, size: CGSize(width: view.bounds.width, height: 50))
        addButton.frame = .init(origin: CGPoint(x: view.bounds.width - 50, y: 0), size: CGSize(width: 50, height: 50))
        
        updateBackground()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        nameField.frame = .init(origin: CGPoint(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top), size: CGSize(width: view.bounds.width, height: 50))
        addButton.frame = .init(origin: CGPoint(x: view.bounds.width - view.safeAreaInsets.right - 50, y: view.safeAreaInsets.top), size: CGSize(width: 50, height: 50))
        collision.setTranslatesReferenceBoundsIntoBoundary(with: UIEdgeInsets(top: -1000, left: 0, bottom: view.safeAreaInsets.bottom, right: 0))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        appDelegate.saveContext()
    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        guard let subwordVC = vc as? SemSetSubwordVC else {
            super.show(vc, sender: sender)
            return
        }
        
        //
        addChild(subwordVC)
        subwordVC.view.frame = .init(origin: .init(x: Int.random(in: 90...280), y: -180), size: .init(width: 180, height: 180))
        view.addSubview(subwordVC.view)
        subwordVC.didMove(toParent: self)
        
        //
        subwordVC.view.alpha = 0
        UIView.animate(withDuration: Self.fadeInDuration) {
            subwordVC.view.alpha = 1
        }
        
        //
        let item = EclipseCollisionBoundsWrapper(subwordVC.view)
        subwordVC.dynamicItem = item
        gravity.addItem(item)
        collision.addItem(item)
        
        subwordVC.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(subwordPanned)))
    }
}

// Adaptive
extension SemSetVC {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
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
            var index = self.gravity.items.count - 1
            Timer.scheduledTimer(withTimeInterval: Self.fallingDuration, repeats: true) { (timer) in
                guard index >= 0 else {
                    timer.invalidate()
                    return
                }
                
                let item = self.gravity.items[index] as! EclipseCollisionBoundsWrapper
                item.center = CGPoint(x: Int.random(in: 90...Int(size.width-90)), y: -180)
                self.animator.updateItem(usingCurrentState: item)
                UIView.animate(withDuration: Self.fadeInDuration) {
                    item.view.alpha = 1
                }
                
                index -= 1
            }
        })
    }
}

// MARK: Manage
extension SemSetVC {
    private func addSubwordVC(_ semSetSubwordVC: SemSetSubwordVC) {
        rootView2VC[semSetSubwordVC.view] = semSetSubwordVC
        show(semSetSubwordVC, sender: self)
    }
    
    private func removeSubwordVC(_ semSetSubwordVC: SemSetSubwordVC) {
        rootView2VC[semSetSubwordVC.view] = nil
        
        semSetSubwordVC.willMove(toParent: nil)
        
        animator.behaviors.forEach {
            switch $0 {
            case let gravity as UIGravityBehavior:
                gravity.removeItem(semSetSubwordVC.dynamicItem!)
            case let collision as UICollisionBehavior:
                collision.removeItem(semSetSubwordVC.dynamicItem!)
            default:
                break
            }
        }
        
        semSetSubwordVC.view.removeFromSuperview()
        semSetSubwordVC.removeFromParent()
        
        word.subWords?.removeAll {
            $0 == semSetSubwordVC.subwordName
        }
    }
}

// MARK: User Interaction
extension SemSetVC {
    @objc func addSubWord() {
        if word.subWords == nil {
            word.subWords = [String]()
        }
        
        guard word.subWords!.count < 5 else {
            return
        }
        
        word.subWords!.append(Self.hintText)
        addSubwordVC(SemSetSubwordVC(text: Self.hintText, delegate: self))
    }
    
    @objc func subwordPanned(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            let dynamicItem = rootView2VC[gesture.view!]!.dynamicItem!
            attatchment = UIAttachmentBehavior(item: dynamicItem, offsetFromCenter: .zero, attachedToAnchor: gesture.location(in: gesture.view!.superview!))
            animator.addBehavior(attatchment)
        case .changed:
            attatchment.anchorPoint = gesture.location(in: gesture.view!.superview!)
        case .ended:
            animator.removeBehavior(attatchment)
            let velocity = gesture.velocity(in: gesture.view!.superview!)
            guard velocity.y < 0 else {
                return
            }
            let dynamicItem = rootView2VC[gesture.view!]!.dynamicItem!
            dynamic = UIDynamicItemBehavior(items: [dynamicItem])
            dynamic.action = {
                guard let superview = gesture.view!.superview else {
                    return
                }
                if !superview.bounds.intersects(gesture.view!.frame) {
                    self.animator.removeBehavior(self.dynamic)
                    self.removeSubwordVC(self.rootView2VC[gesture.view!]!)
                }
            }
            dynamic.addLinearVelocity(.init(x: 0, y: velocity.y), for: dynamicItem)
            animator.addBehavior(dynamic)
        default:
            return
        }
    }
}

// Mark: Network
extension SemSetVC {
    private func updateBackground() {
        task?.cancel()
        task = URLSession.shared.dataTask(with: NetworkSpace.bgImageQueryingURL(forWord: word.name!)) { [weak self] (data, response, error) in
            if self == nil {
                return
            }
            
            guard NetworkSpace.validate(error: error, response: response) else {
                return
            }
            if let data = data, let imagePath = String(data: data, encoding: .utf8), let url = URL(string: imagePath) {
                DispatchQueue.main.async {
                    self?.background.kf.setImage(with: url)
                }
            }
        }
        task?.resume()
    }
}

extension SemSetVC: SemTextViewDelegate {
    static private let hintText = "unset"
    
    func semTextView(_ semTextView: SemTextView, didTapNotelink link: String) {
        
    }
    
    func semTextView(_ semTextView: SemTextView, didAddNotelinks added: Set<String>, didRemoveNotelinks removed: Set<String>) {
        CoreDataLayer1.shared.createLinks(oneEndWordName: word.name!, theOtherEndWordsName: added)
        CoreDataLayer1.shared.deleteLinks(oneEndWordName: word.name!, theOtherEndWordsName: removed)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isFirstEditing && textView.text == Self.hintText {
            textView.text = ""
            isFirstEditing = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        word.name = textView.text.removingNeighborWords()
        updateBackground()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        super.touchesBegan(touches, with: event)
    }
}

extension SemSetVC: SemSetSubwordVCDelegate {
    func upadteSubword(oldText: String, newText: String) {
        if let index = word.subWords?.firstIndex(of: oldText) {
            word.subWords?[index] = newText
        }
    }
}
