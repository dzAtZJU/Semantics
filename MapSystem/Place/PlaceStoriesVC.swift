import UIKit
import FloatingPanel

class PlaceStoriesVC: UIPageViewController, PanelContent {
    //
    var allowsEditing = true
    
    let showBackBtn = true
    
    var prevPanelState:  FloatingPanelState?
    
    var panelContentDelegate: PanelContentDelegate!
    //
    
    private var pageIndex = 0
    
    private let vm: PlaceStoriesVM
    init(vm: PlaceStoriesVM) {
        self.vm = vm
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = PlaceStoryVC(style: .Card)
        vc.vm = vm.firstPlaceStoryVM
        vc.allowsEditing = false
        setViewControllers([vc], direction: .forward, animated: false, completion: nil)
    }
}

extension PlaceStoriesVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? PlaceStoryVC else {
            fatalError()
        }
        
        let newVC = PlaceStoryVC(style: .Card)
        newVC.vm = vm.placeStoryVM(before: vc.vm)
        newVC.allowsEditing = false
        return newVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? PlaceStoryVC else {
            fatalError()
        }
        
        let newVC = PlaceStoryVC(style: .Card)
        newVC.vm = vm.placeStoryVM(after: vc.vm)
        newVC.allowsEditing = true
        return newVC
    }
}
