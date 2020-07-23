//
//  TestVC.swift
//  SemanticsTests
//
//  Created by Zhou Wei Ran on 2020/7/21.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import Jelly

class TestVC: UIViewController {
    var animator: Jelly.Animator?
    
    let newVC = SideVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemPink
        view.cornerRadius = 50

        
        let interaction = InteractionConfiguration(presentingViewController: self, completionThreshold: 0.5, dragMode: .canvas)
        let uiConfigs = PresentationUIConfiguration(backgroundStyle: .dimmed(alpha: 0.7))
        let slide = SlidePresentation(uiConfiguration: uiConfigs, direction: .left, size: .custom(value: 340), parallax: 0.1, interactionConfiguration: interaction)
        animator = Animator(presentation: slide)
        animator?.prepare(presentedViewController: newVC)
    }
}

class SideVC: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .systemYellow
        view.cornerRadius = 50
        
        let imgView = UIImageView(image: UIImage(named: "mimosa_pudica")!)
        imgView.frame = view.bounds
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imgView)
    }
}
