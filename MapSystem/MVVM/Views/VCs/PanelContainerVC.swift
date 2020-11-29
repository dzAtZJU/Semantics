import UIKit
import MapKit
import FloatingPanel
import RealmSwift

protocol PanelContent: Reusable, UIViewController {
    var allowsEditing: Bool {
        get
    }
    
    var backItem: PanelContainerVC.BackItem {
        get
    }
    
    var panelContentDelegate: PanelContentDelegate! { get set }
    
    var prevPanelState:  FloatingPanelState? {
        get
        set
    }
}

protocol PanelContentDelegate {
    var panel: FloatingPanelController {
        get
    }
    
    var panelContainerVC: PanelContainerVC {
        get
    }
    
    var mapVM: AMapVM {
        get
    }
    
    var map: MKMapView {
        get
    }
}

class PanelContainerVC: UIViewController {
    struct BackItem {
        let showBackBtn: Bool
        let action: (()->())?
    }
    
    static private var duration: Double = 0
    
    var initialVC: PanelContent?
    var currentVC: PanelContent?
    init(initialVC initialVC_: PanelContent) {
        initialVC = initialVC_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var backBtn: UIButton = UIButton(
        systemName: "multiply.circle.fill", textStyle: .title1, target: self, selector: #selector(backBtnTapped))
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        view.addSubview(backBtn)
        view.trailingAnchor.constraint(equalToSystemSpacingAfter: backBtn.trailingAnchor, multiplier: 2).isActive = true
        backBtn.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 2).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if initialVC != nil {
            show(initialVC!, sender: nil)
        }
    }
    
    private lazy var dispatchGroup = DispatchGroup()
    private lazy var queue = DispatchQueue(label: "Dedicated-For-PanelContentVC")
    override func show(_ vc: UIViewController, sender: Any?) {
        queue.async {
            self.dispatchGroup.wait()
            self.dispatchGroup.enter()
            guard let vc = vc as? PanelContent else {
                fatalError()
            }
            
            DispatchQueue.main.async {
                self.addChild(vc)
                vc.view.frame = self.view.bounds.inset(by: self.view.safeAreaInsets)
                vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                vc.view.transform = .init(translationX: 0, y: self.view.height)
                self.view.addSubview(vc.view)
                self.view.addSubview(self.backBtn)
                UIView.animate(withDuration: Self.duration, animations: {
                    vc.view.transform = .identity
                    self.backBtn.isHidden = !vc.backItem.showBackBtn
                }) { _ in
                    vc.didMove(toParent: self)
                    if vc.isEqual(self.initialVC) {
                        self.initialVC = nil
                        Self.duration = 0.25
                    }
                    self.dispatchGroup.leave()
                }
            }
        }
    }
    
    func hideAll() {
        queue.async {
            self.dispatchGroup.wait()
            self.dispatchGroup.enter()
            self.hideAll_ {
                self.dispatchGroup.leave()
            }
        }
    }
    
    func hideTop() {
        queue.async {
            self.dispatchGroup.wait()
            self.dispatchGroup.enter()
            self.hideTop_() { _ in
                self.dispatchGroup.leave()
            }
        }
    }
    
    private func hideTop_(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            guard self.children.count >= 2, let vc = self.children.last as? PanelContent else {
                completion(true)
                return
            }
            
            var vcWillShow: PanelContent?
            
            if case let suffix2 = self.children.suffix(2), suffix2.count == 2 {
                vcWillShow = suffix2.first as? PanelContent
            }
            
            vc.willMove(toParent: nil)
            UIView.animate(withDuration: Self.duration, animations: {
                vc.view.transform = .init(translationX: 0, y: self.view.height)
                if let vcWillShow = vcWillShow {
                    self.backBtn.isHidden = !vcWillShow.backItem.showBackBtn
                }
            }) { _ in
                vc.view.removeFromSuperview()
                vc.view.transform = .identity
                vc.removeFromParent()
                completion(false)
            }
        }
    }
    
    private func hideAll_(completion: @escaping () -> Void) {
        hideTop_ {
            if $0 {
                completion()
            } else {
                self.hideAll_(completion: completion)
            }
        }
    }
}

// MARK: Interaction
extension PanelContainerVC {
    @objc private func backBtnTapped() {
        hideTop()
        (children.last as? PanelContent)?.backItem.action?()
    }
}

extension PanelContainerVC: FloatingPanelControllerDelegate{
}
