//
//  FeedbackVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/14.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import FloatingPanel

class FeedbackVC: UIPageViewController, PanelContent {
    var panelContentVM: PanelContentVM! {
        nil
    }
    
    let showBackBtn = true
    
    var topInset: CGFloat = 30
    
    var panelContentDelegate: PanelContentDelegate!
    
    private weak var scrollView: UIScrollView?
    
    private var pageIndex = 0
    
    private let feedbackVM: FeedbackVM
    init(feedbackVM feedbackVM_: FeedbackVM) {
        feedbackVM = feedbackVM_
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        dataSource = self
        setViewControllers([ConditionFeedbackVC(conditionFeedbackVM: feedbackVM.firstConditionFeedbackVM)], direction: .forward, animated: false, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        panelContentDelegate.panel.move(to: .full, animated: true)
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        panelContentDelegate.panel.move(to: .half, animated: true)
        super.viewWillDisappear(animated)
    }
}

extension FeedbackVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = (viewController as! ConditionFeedbackVC)
        guard let vm = feedbackVM.conditionFeedbackVM(before: vc.conditionFeedbackVM) else {
            return nil
        }
        return ConditionFeedbackVC(conditionFeedbackVM: vm)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = (viewController as! ConditionFeedbackVC)
        guard let vm = feedbackVM.conditionFeedbackVM(after: vc.conditionFeedbackVM) else {
            return nil
        }
        return ConditionFeedbackVC(conditionFeedbackVM: vm)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        feedbackVM.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        pageIndex
    }
}

extension FeedbackVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {
            return
        }
        
        guard let conditionFeedbackVC = pageViewController.viewControllers?.first as? ConditionFeedbackVC else {
            fatalError("FeedbackVC as UIPageViewControllerDelegate get called with UIPageViewController containing non-ConditionFeedbackVC")
        }
        
        pageIndex = feedbackVM.indexFor(conditionFeedbackVM: conditionFeedbackVC.conditionFeedbackVM)
    }
}