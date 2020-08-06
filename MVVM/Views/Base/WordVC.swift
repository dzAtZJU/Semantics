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

class WordVC: UIViewController {
    private static let fallingDuration = 0.4
    
    private static let fadeInDuration = 2.0
    
    private var activeFirstResponder: UIResponder?
    
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
    
    private lazy var communityButton: UIButton = {
        let tmp = UIButton()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        
        tmp.setImage(UIImage(systemName: "folder.badge.person.crop", withConfiguration: UIImage.SymbolConfiguration(textStyle: .title3)), for: .normal)
        tmp.addTarget(self, action: #selector(communityButtonTapped), for: .touchUpInside)
        return tmp
    }()
    
    private lazy var addButton: UIButton = {
        let tmp = UIButton(type: .contactAdd)
        tmp.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        tmp.contentVerticalAlignment = .fill
        tmp.contentHorizontalAlignment = .fill
        tmp.addTarget(self, action: #selector(addSubWord), for: .touchUpInside)
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
    private var attatchment: UIAttachmentBehavior!
    
    private var isFirstEditing = true
    
    private var word: Word!
    
    private var task: URLSessionDataTask?
    
    lazy private var rootView2VC = [UIView: SubwordVC]()
    
    lazy private var runningAnimators = [UIViewPropertyAnimator]()
    
    init(word word_: Word?, proximity: Int = 5) {
        super.init(nibName: nil, bundle: nil)
        
        if let word_ = word_ {
            word = word_
        } else if let title = title {
            let request: NSFetchRequest<Word> = Word.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", title)
            let resutls = try! appManagedObjectContext.fetch(request)
            word = resutls.first
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        task?.cancel()
    }
    
    // MARK: Override
    override func loadView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareBtnTapped))
        
        view = UIView()
        view.backgroundColor = .systemBackground
        view.addSubview(background)
        view.addSubview(nameField)
        if word.communityRecordIDs?.count ?? 0 > 0 {
            view.addSubview(communityButton)
        }
        view.addSubview(addButton)
    }
    
    override func viewDidLoad() {
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        animator.addBehavior(dynamicBahav)
        
        if word.subWords != nil, word.subWords!.capacity > 0 {
            var index = 0
            Timer.scheduledTimer(withTimeInterval: Self.fallingDuration, repeats: true) { timer in
                self.addSubwordVC(SubwordVC(text: self.word.subWords![index]))
                index += 1
                if index == self.word.subWords!.endIndex {
                    timer.invalidate()
                }
            }.fire()
        }
    
        if word.communityRecordIDs?.count ?? 0 > 0 {
            communityButton.bottomAnchor.constraint(equalTo: nameField.lastBaselineAnchor).isActive = true
            communityButton.trailingAnchor.constraint(lessThanOrEqualTo: nameField.readableContentGuide.trailingAnchor).isActive = true
        }
        
        updateBackground()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(floatMoved), name: .floatMoved, object: nil)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        nameField.frame.origin = view.bounds.inset(by: view.safeAreaInsets).origin
        nameField.size = CGSize(width: view.bounds.width, height: nameField.sizeThatFits(CGSize(width: view.bounds.width, height: 0)).height)
        addButton.center = view.bounds.inset(by:
            view.safeAreaInsets).bottomRight - CGPoint(x: 40, y: 40)
        addButton.bounds.size = CGSize(width: 40, height: 40)
        collision.setTranslatesReferenceBoundsIntoBoundary(with: UIEdgeInsets(top: -1000, left: 0, bottom: view.safeAreaInsets.bottom, right: 0))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .floatMoved, object: nil)
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
        view.insertSubview(subwordVC.view, belowSubview: addButton)
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
        
        subwordVC.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(subwordPanned)))
    }
}

// Adaptive
extension WordVC {
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
}

// MARK: Manage
extension WordVC {
    private func addSubwordVC(_ wordVC: SubwordVC) {
        wordVC.delegate = self
        rootView2VC[wordVC.view] = wordVC
        show(wordVC, sender: self)
    }
    
    private func removeSubwordVC(_ semSetSubwordVC: SubwordVC) {
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
extension WordVC {
    @objc private func addSubWord() {
        if word.subWords == nil {
            word.subWords = [String]()
        }

        guard word.subWords!.count < 5 else {
            return
        }

        word.subWords!.append(Self.hintText)
        addSubwordVC(SubwordVC(text: Self.hintText))
    }
    
    @objc private func communityButtonTapped() {
        let communityVM = CommunityVM(word: word)
        communityVM.loadRecords {
            DispatchQueue.main.async {
                self.parent!.show(CommunityVC(community: communityVM), sender: nil)
            }
        }
    }
    
    @objc private func shareBtnTapped() {
        let record = CoreDataSpace.shared.persistentContainer.record(for: word.objectID)!

        CloukitSpace.shared.container.prepareSharingController(rootRecord: record, database: CloukitSpace.shared.container.privateCloudDatabase) { sharingController in
            self.present(sharingController!, animated: true, completion: nil)
        }
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
            dynamicBahav.action = {
                guard let superview = gesture.view!.superview else {
                    return
                }
                if !superview.bounds.intersects(gesture.view!.frame) {
                    self.removeSubwordVC(self.rootView2VC[gesture.view!]!)
                }
            }
            dynamicBahav.addLinearVelocity(.init(x: 0, y: velocity.y), for: dynamicItem)
        default:
            return
        }
    }
}

// Mark: Network
extension WordVC {
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

extension WordVC: SemTextViewDelegate {
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

extension WordVC: SemSetSubwordVCDelegate {
    func didChangeFirstResponderState(semSetSubwordVC: SubwordVC, to: Bool) {
        guard to else {
            activeFirstResponder = nil
            return
        }
        
        activeFirstResponder = semSetSubwordVC.textView
    }
    
    func upadteSubword(oldText: String, newText: String) {
        if let index = word.subWords?.firstIndex(of: oldText) {
            word.subWords?[index] = newText
        }
    }
}

extension WordVC {
    @objc private func keyboardDidShow(notification: Notification) {
        guard let activeFirstResponder = activeFirstResponder else {
            return
        }
        
        let kbFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect)
        let frFrame = activeFirstResponder.globalFrame!
        print("kb: \(kbFrame) \(frFrame)")
        if frFrame.intersects(kbFrame) {
            animator.removeAllBehaviors()
            UIView.animate(withDuration: 0.25) {
                self.view.bounds.origin.y += kbFrame.height
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.bounds.origin.y = 0
        }) { _ in
            self.animator.addBehavior(self.gravity)
            self.animator.addBehavior(self.collision)
        }
    }
    
    @objc private func floatMoved(notification: Notification) {
        guard let floatCenter = (notification.object as? Notification.FloatMoved)?.center else {
            return
        }
        
        if nameField.superview!.convert(nameField.frame, to: nil).contains(floatCenter) {
            NotificationCenter.default.post(name: .floatAdding, object: Notification.FloatAdding(word: word))
            (self.view.window!.rootViewController as! FloatContainerVC).removeVC()
        }
    }
}
