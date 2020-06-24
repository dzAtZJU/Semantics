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

@objc
protocol SemSetVCDelegate {
    @objc optional func back()
}

class SemSetVC: UIViewController {
    private var isFirstEditing = true
    
    lazy var nameField: SemTextView = {
        let tmp = SemTextView(frame: .zero)
        tmp.text = word.name?.appending(neighborWords: Set(word.neighborWordsName))
        tmp.font = UIFont.preferredFont(forTextStyle: .title3)
        
        tmp.backgroundColor = .lightGray
        tmp.textColor = .white
        tmp.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        tmp.delegate = self
        return tmp
    }()
    
    lazy var addButton: UIButton = {
        let temp = UIButton(type: .contactAdd)
        temp.addTarget(self, action: #selector(Self.addSubWord), for: .touchUpInside)
        return temp
    }()
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var gravity = UIGravityBehavior()
    lazy var collision: UICollisionBehavior = {
        let temp = UICollisionBehavior()
        temp.setTranslatesReferenceBoundsIntoBoundary(with: .init(top: -1000, left: 0, bottom: 0, right: 0))
        return temp
    }()
    
    var delegate: SemSetVCDelegate?
    
    private var word: Word! = nil
    
    init(word word_: Word?, title: String?) {
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
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .black
        view.addSubview(nameField)
        view.addSubview(addButton)
    }
    
    override func viewDidLoad() {
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        
        if word.subWords != nil, word.subWords!.capacity > 0 {
            var index = 0
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
                self.constructSubwordVC(self.word.subWords![index])
                index += 1
                if index == self.word.subWords!.endIndex {
                    timer.invalidate()
                }
            }
        }
        
        nameField.frame = .init(origin: .zero, size: CGSize(width: view.bounds.width, height: 50))
        addButton.frame = .init(origin: CGPoint(x: view.bounds.width - 50, y: 0), size: CGSize(width: 50, height: 50))
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        nameField.frame = .init(origin: CGPoint(x: view.safeAreaInsets.left, y: view.safeAreaInsets.top), size: CGSize(width: view.bounds.width, height: 50))
        addButton.frame = .init(origin: CGPoint(x: view.bounds.width - view.safeAreaInsets.right - 50, y: view.safeAreaInsets.top), size: CGSize(width: 50, height: 50))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        appDelegate.saveContext()
    }
    
    var push: UIPushBehavior!
    
    @objc func addSubWord() {
        if word.subWords == nil {
            word.subWords = [String]()
        }

        guard word.subWords!.count < 5 else {
            return
        }

        word.subWords!.append(Self.hintText)
        constructSubwordVC(Self.hintText)
    }
    
    func constructSubwordVC(_ text: String) {
        let vc = SemSetSubwordVC(text: text, delegate: self)
        
        addChild(vc)
        vc.view.frame = .init(origin: .init(x: Int.random(in: 90...280), y: -180), size: .init(width: 180, height: 180))
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        let item = EclipseCollisionBoundsWrapper(vc.view)
        vc.dynamicItem = item
        gravity.addItem(item)
        collision.addItem(item)
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
        super.touchesBegan(touches, with: event)
    }
}

extension SemSetVC: SemSetSubwordVCDelegate {
    func removeIt(_ semSetSubwordVC: SemSetSubwordVC, text: String) {
        semSetSubwordVC.willMove(toParent: nil)
        
        animator.behaviors.forEach {
            switch $0 {
            case let gravity as UIGravityBehavior:
                gravity.removeItem(semSetSubwordVC.dynamicItem!)
            case let collision as UICollisionBehavior:
                collision.removeItem(semSetSubwordVC.dynamicItem!)
            default:
                fatalError()
            }
        }
        
        semSetSubwordVC.view.removeFromSuperview()
        semSetSubwordVC.removeFromParent()
        
        word.subWords?.removeAll {
            $0 == text
        }
    }
    
    func upadteSubword(oldText: String, newText: String) {
        if let index = word.subWords?.firstIndex(of: oldText) {
            word.subWords?[index] = newText
        }
    }
}