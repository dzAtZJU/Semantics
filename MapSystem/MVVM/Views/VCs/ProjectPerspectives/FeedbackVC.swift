import UIKit
import FloatingPanel

class FeedbackVC: UIPageViewController, PanelContent {
    var allowsEditing = true
    
    let backItem = PanelContainerVC.BackItem(showBackBtn: true, action: nil)
    
    var prevPanelState:  FloatingPanelState?
    
    var panelContentDelegate: PanelContentDelegate!
    
    private var pageIndex = 0
    
    private let feedbackVM: FeedbackVM
    init(feedbackVM feedbackVM_: FeedbackVM) {
        feedbackVM = feedbackVM_
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let vc = ConditionFeedbackVC(conditionFeedbackVM: feedbackVM.firstConditionFeedbackVM)
        vc.allowsEditing = allowsEditing
        setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.panelContentDelegate.panel.move(to: .half, animated: false)
        }
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.panelContentDelegate.panel.move(to: .tip, animated: false)
        }
        super.viewWillDisappear(animated)
    }
}

extension FeedbackVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = (viewController as! ConditionFeedbackVC)
        guard let vm = feedbackVM.conditionFeedbackVM(before: vc.conditionFeedbackVM) else {
            return nil
        }
        let newVC = ConditionFeedbackVC(conditionFeedbackVM: vm)
        newVC.allowsEditing = allowsEditing
        return newVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = (viewController as! ConditionFeedbackVC)
        guard let vm = feedbackVM.conditionFeedbackVM(after: vc.conditionFeedbackVM) else {
            return nil
        }
        let newVC = ConditionFeedbackVC(conditionFeedbackVM: vm)
        newVC.allowsEditing = allowsEditing
        return newVC
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
