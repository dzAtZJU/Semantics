//
//  SemanticsSetView.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/5/24.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import SwiftUI
import CoreData

struct SemanticsSetView: UIViewControllerRepresentable {
    
    let word: Word?
    
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    func updateUIViewController(_ uiViewController: SemanticsSetVC, context: Context) {
    }
    
    func makeUIViewController(context: Context) -> SemanticsSetVC {
        let vc = SemanticsSetVC()
        vc.word = word
        vc.delegate = context.coordinator
        return vc
    }
    
    class Coordinator: SemanticsSetVCDelegate {
        let parent: SemanticsSetView
        
        init(parent: SemanticsSetView) {
            self.parent = parent
        }
    }
}

//struct SemanticsSetView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        let word = Word(context: context)
//        word.name = "word"
//        word.subWords = ["1", "23", "456"]
//        return SemanticsSetView(word: word)
//    }
//}

@objc
protocol SemanticsSetVCDelegate {
    @objc optional func back()
}

class SemanticsSetVC: UIViewController {
    lazy var nameField: UITextField = {
        let tmp = UITextField()
        tmp.text = word?.name
        tmp.backgroundColor = .lightGray
        tmp.textColor = .white
        tmp.attributedPlaceholder = NSAttributedString(string: "input name here", attributes:[.foregroundColor: UIColor.white])
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
    
    var delegate: SemanticsSetVCDelegate?
    
    var word: Word!
    
    override func viewDidLoad() {
        view.backgroundColor = .black
        
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        
        if word?.subWords != nil {
            var index = 0
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
                self.constructCircleTextView(self.word.subWords![index])
                index += 1
                if index == self.word.subWords!.endIndex {
                    timer.invalidate()
                }
            }
        }
        
        view.addSubview(nameField)
        view.addSubview(addButton)
        
        if word == nil {
            word = Word(context: managedObjectContext)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameField.frame = .init(origin: .zero, size: CGSize(width: view.bounds.width, height: 50))
        addButton.frame = .init(origin: .init(x: view.bounds.width - 50, y: 0), size: CGSize(width: 50, height: 50))
        
        super.viewWillAppear(animated)
    }
    
    @objc func addSubWord() {
        if word.subWords == nil {
            word.subWords = [String]()
        }

        guard word.subWords!.count < 5 else {
            return
        }

        word.subWords!.append("new item")
        constructCircleTextView("new item")
    }
    
    func constructCircleTextView(_ text: String) {
        var textOnCircle = TextOnCircle(text)
        textOnCircle.delegate = self
        let vc = UIHostingController(rootView: textOnCircle)
        
        addChild(vc)
        vc.view.frame = .init(origin: .init(x: Int.random(in: 90...280), y: -180), size: .init(width: 180, height: 180))
        vc.view.backgroundColor = nil
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        let item = EclipseCollisionBoundsWrapper(vc.view)
        gravity.addItem(item)
        collision.addItem(item)
    }
}

extension SemanticsSetVC: TextOnCircleDelegate {
    func onCommit(oldText: String, newText: String) {
        if let index = word.subWords?.firstIndex(of: oldText) {
            word.subWords!.remove(at: index)
            word.subWords!.append(newText)
        }
    }
}

extension SemanticsSetVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        word.name = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
