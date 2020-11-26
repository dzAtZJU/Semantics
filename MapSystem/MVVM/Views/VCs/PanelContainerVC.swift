import UIKit
import MapKit
import FloatingPanel
import RealmSwift

protocol PanelContent: Reusable, UIViewController {
    var allowsEditing: Bool {
        get
    }
    
    var showBackBtn: Bool { get }
    
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
    
    var mapVM: MapVM {
        get
    }
    
    var map: MKMapView {
        get
    }
}

protocol PanelContainerVCDelegate {
    func panelContentVC(_ panelContentVC: PanelContainerVC,
    didShow panelContent: PanelContent,
    animated: Bool)
    
    func panelContentVC(_ panelContentVC: PanelContainerVC,
    willHide panelContent: PanelContent,
    animated: Bool)
    
    func panelContentVCWillBack(_ panelContentVC: PanelContainerVC)
}

class PanelContainerVC: UIViewController {
    static private var duration: Double = 0
    var delegate: PanelContainerVCDelegate!
    
    var initialVC: UIViewController?
    var currentVC: UIViewController?
    init(initialVC initialVC_: UIViewController) {
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
                if let top = self.children.last as? PanelContent {
                    self.delegate.panelContentVC(self, willHide: top, animated: true)
                }
                
                self.addChild(vc)
                print("SafeArea: \(self.view.safeAreaInsets)")
                vc.view.frame = self.view.bounds.inset(by: self.view.safeAreaInsets)
                vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                vc.view.transform = .init(translationX: 0, y: self.view.height)
                self.view.addSubview(vc.view)
                self.view.addSubview(self.backBtn)
                UIView.animate(withDuration: Self.duration, animations: {
                    vc.view.transform = .identity
                    self.backBtn.isHidden = !vc.showBackBtn
                }) { _ in
                    vc.didMove(toParent: self)
                    if vc == self.initialVC {
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
                    self.backBtn.isHidden = !vcWillShow.showBackBtn
                }
            }) { _ in
                vc.view.removeFromSuperview()
                vc.view.transform = .identity
                vc.removeFromParent()
                if let vcWillShow = vcWillShow {
                    self.delegate.panelContentVC(self, didShow: vcWillShow, animated: true)
                }
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
        delegate.panelContentVCWillBack(self)
    }
}

extension PanelContainerVC: FloatingPanelControllerDelegate{
}
