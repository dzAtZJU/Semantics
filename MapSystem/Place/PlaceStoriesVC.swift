import UIKit
import FloatingPanel

class PlaceStoriesVC: UIPageViewController, PanelContent {
    //
    var allowsEditing = true
    
    lazy var backItem = PanelContainerVC.BackItem(showBackBtn: true, action: {
        self.panelContentDelegate.map.deselectAnnotation(nil, animated: true)
    })
    
    var prevPanelState:  FloatingPanelState?
    
    var panelContentDelegate: PanelContentDelegate!
    //
    
    var placeStoryVCDelegate: PlaceStoryVCDelegate?
    
    private var pageIndex = 0
    
    var vm: PlaceStoriesVM! {
        didSet {
            DispatchQueue.main.async {
                let newVM = self.vm.firstPlaceStoryVM
                let vc = self.createPlaceStoryVC(vm: newVM)
                self.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
            }
        }
    }
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing: NSNumber(floatLiteral: 10)])
        
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    private func createPlaceStoryVC(vm: PlaceStoryVM) -> PlaceStoryVC {
        let newVC = PlaceStoryVC(style: .Card)
        newVC.vm = vm
        newVC.allowsEditing = vm.ownerID == RealmSpace.userID
        newVC.delegate = placeStoryVCDelegate
        return newVC
    }
}

extension PlaceStoriesVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? PlaceStoryVC else {
            fatalError()
        }
        guard let vm = vm.placeStoryVM(before: vc.vm as! PlaceStoryVM) else {
            return nil
        }
        
        return createPlaceStoryVC(vm: vm)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? PlaceStoryVC else {
            fatalError()
        }
        guard let vm = vm.placeStoryVM(after: vc.vm as! PlaceStoryVM) else {
            return nil
        }
        
        return createPlaceStoryVC(vm: vm)
    }
}
