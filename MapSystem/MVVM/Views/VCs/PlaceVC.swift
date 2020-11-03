import UIKit
import Combine
import TagListView
import Presentr
import FloatingPanel

protocol PlaceVCDelegate {
    func placeVCShouldStartIndividualAble(_ placeVC: PlaceVC)
    
    func placeVCShouldHumankindAble(_ placeVC: PlaceVC)
    
    func placeVCShouldCollect(_ placeVC: PlaceVC)
    
    func placeWillDisappear(_ placeVC: PlaceVC)
}

class PlaceVC: UIViewController, PanelContent {
    var prevPanelState:  FloatingPanelState?
    
    private lazy var stackView: UIStackView = {
        let tmp = UIStackView()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.axis = .horizontal
        tmp.alignment = .center
        tmp.spacing = 30
        return tmp
    }()
    
    private lazy var collectBtn: UIButton = {
        let tmp = UIButton(type: .roundedRect)
        tmp.cornerRadius = 10
        tmp.setTitleForAllStates("Collect")
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.addTarget(self, action: #selector(markVisitedBtnTapped), for: .touchUpInside)
        tmp.backgroundColor = .systemBlue
        tmp.tintColor = .white
        tmp.widthAnchor.constraint(equalToConstant: 150).isActive = true
        tmp.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tmp
    }()
    
    private lazy var individualAbleBtn: UIButton = {
        let tmp = UIButton(type: .roundedRect)
        tmp.cornerRadius = 10
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.addTarget(self, action: #selector(feedbackBtnTapped), for: .touchUpInside)
        tmp.backgroundColor = .systemBlue
        tmp.tintColor = .white
        tmp.widthAnchor.constraint(equalToConstant: 150).isActive = true
        tmp.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tmp
    }()
    
    private lazy var humankindAbleBtn: UIButton = {
        let tmp = UIButton(type: .roundedRect)
        tmp.cornerRadius = 10
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.addTarget(self, action: #selector(findNextBtnTapped), for: .touchUpInside)
        tmp.backgroundColor = .systemBlue
        tmp.tintColor = .white
        tmp.widthAnchor.constraint(equalToConstant: 150).isActive = true
        tmp.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return tmp
    }()
    
    private lazy var tagsView: TagListView = {
        let tmp = TagListView()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.textFont = .preferredFont(forTextStyle: .title3)
        tmp.tagBackgroundColor = .systemGreen
        tmp.marginX = 6
        tmp.marginY = 6
        tmp.alignment = .center
        tmp.delegate = self
        tmp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(placePerspectivesTapped)))
        return tmp
    }()
    
    var panelContentVM: PanelContentVM!
    
    var vm: PlaceVM! {
        didSet {
            placeStateToken = vm.$placeState.sink { newValue in
                DispatchQueue.main.async {
                    switch newValue {
                    case .neverBeen:
                        self.stackView.addArrangedSubview(self.collectBtn)
                        self.stackView.removeArrangedSubview(self.individualAbleBtn)
                        self.individualAbleBtn.removeFromSuperview()
                        self.stackView.removeArrangedSubview(self.humankindAbleBtn)
                        self.humankindAbleBtn.removeFromSuperview()
                        break
                    case .visited, .feedbacked:
                        self.stackView.removeArrangedSubview(self.collectBtn)
                        self.collectBtn.removeFromSuperview()
                        self.individualAbleBtn.setTitleForAllStates(self.vm.interactionTitles!.individualAble)
                        self.stackView.addArrangedSubview(self.individualAbleBtn)
                        self.humankindAbleBtn.setTitleForAllStates(self.vm.interactionTitles!.humankindAble)
                        self.stackView.addArrangedSubview(self.humankindAbleBtn)
                        break
                    }
                }
            }
            tagsToken = vm.$tags.sink {
                guard var perspectives = $0 else {
                    self.tagsView.removeAllTags()
                    return
                }
                if perspectives.isEmpty {
                    perspectives.append("add \(self.vm.interactionTitles!.anchor)")
                }
                DispatchQueue.main.async {
                    self.tagsView.removeAllTags()
                    self.tagsView.addTags(perspectives)
                    self.tagsView.tagViews.forEach {
                        $0.layer.cornerRadius = 10
                        $0.layer.masksToBounds = true
                    }
                }
            }
        }
    }
    
    var placeStateToken: AnyCancellable?
    
    var tagsToken: AnyCancellable?
    
    var panelContentDelegate: PanelContentDelegate!
    
    let showBackBtn = true
    
    var delegate: PlaceVCDelegate?
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 10).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(tagsView)
        tagsView.topAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 4).isActive = true
        tagsView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2).isActive = true
        view.trailingAnchor.constraint(equalToSystemSpacingAfter: tagsView.trailingAnchor, multiplier: 2).isActive = true
        
    }
            
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.placeWillDisappear(self)
    }
}

// MARK: Interaction
extension PlaceVC: TagListViewDelegate {
    @objc private func feedbackBtnTapped() {
        guard !vm.tags!.isEmpty else {
            placePerspectivesTapped()
            return
        }
        delegate?.placeVCShouldStartIndividualAble(self)
    }
    
    @objc private func markVisitedBtnTapped() {
        delegate?.placeVCShouldCollect(self)
    }
    
    @objc private func findNextBtnTapped() {
        delegate?.placeVCShouldHumankindAble(self)
    }
    
    @objc private func placePerspectivesTapped() {
        let vc = TagsVC(tagChoice_List: vm.tagChoice_List, title: vm.interactionTitles!.anchorCollectionTitle, inputingCellPlaceholder: vm.interactionTitles!.anchor, enableAdding: vm.enableAddingTag)
        vc.delegate = vm
        self.customPresentViewController(vc.presentr, viewController: UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    @objc func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        placePerspectivesTapped()
    }
}
