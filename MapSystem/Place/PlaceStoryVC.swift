import UIKit
import Combine
import TagListView
import Presentr
import FloatingPanel
        
protocol APlaceStoryVM: TagsVCDelegate, HavingOwner {
    var partnerProfile: Profile! {
        get
    }
        
    var tagsPublisher: Published<[String]?>.Publisher { get }
    
    var tagChoice_Sections: [TagChoiceSection] {
        get
    }
    
    var ownerID: String! {
        get
    }
}

protocol PlaceStoryVCDelegate {
    func placeStoryVCShouldStartIndividualAble(_ placeStoryVC: PlaceStoryVC, tag: String)
    
    func placeStoryVCShouldHumankindAble(_ placeStoryVC: PlaceStoryVC, tag: String)
}

class PlaceStoryVC: UIViewController, PanelContent {
    enum Style {
        case Card
        case Plain
    }
    
    private let style: Style
    
    var allowsEditing = true
    
    lazy var backItem = PanelContainerVC.BackItem(showBackBtn: true, action: {
        self.panelContentDelegate.map.deselectAnnotation(nil, animated: true)
    })
    
    var prevPanelState:  FloatingPanelState?
    
    private lazy var profileView: AvatarWithNameView = AvatarWithNameView(axis: .horizontal, width: 50)
    
    private lazy var stackView: UIStackView = {
        let tmp = UIStackView()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.axis = .horizontal
        tmp.alignment = .center
        tmp.spacing = 30
        return tmp
    }()
    
    private lazy var individualAbleBtn: UIButton = {
        let tmp = UIButton(type: .roundedRect)
        tmp.cornerRadius = 10
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.addTarget(self, action: #selector(individualAbleBtnTapped), for: .touchUpInside)
        tmp.backgroundColor = .systemBlue
        tmp.tintColor = .white
        tmp.widthAnchor.constraint(equalToConstant: 150).isActive = true
        tmp.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tmp.isHidden = true
        return tmp
    }()
    
    private lazy var humankindAbleBtn: UIButton = {
        let tmp = UIButton(type: .roundedRect)
        tmp.cornerRadius = 10
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.addTarget(self, action: #selector(humankindAbleBtnTapped), for: .touchUpInside)
        tmp.backgroundColor = .systemBlue
        tmp.tintColor = .white
        tmp.widthAnchor.constraint(equalToConstant: 150).isActive = true
        tmp.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tmp.isHidden = true
        return tmp
    }()
    
    private lazy var tagsView: TagListView = {
        let tmp = TagListView()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.textFont = .preferredFont(forTextStyle: .title3)
        tmp.tagBackgroundColor = .systemFill
        tmp.tagSelectedBackgroundColor = .systemBlue
        tmp.marginX = 6
        tmp.marginY = 6
        tmp.alignment = .center
        tmp.delegate = self
        tmp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(placePerspectivesTapped)))
        return tmp
    }()
    
    private var selectedTag: String?
    
    var vm: APlaceStoryVM! {
        didSet {
            tagsToken = vm.tagsPublisher.sink {
                var perspectives = $0 ?? []
                if self.allowsEditing {
                    perspectives.append(addtag)
                }
                DispatchQueue.main.async {
                    self.stackView.arrangedSubviews.forEach {
                        $0.isHidden = true
                    }
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
    
    var tagsToken: AnyCancellable?
    
    var panelContentDelegate: PanelContentDelegate!
    
    var delegate: PlaceStoryVCDelegate?
    
    init(style: Style) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        switch style {
        case .Plain:
            view.backgroundColor = .systemBackground
        case .Card:
            view.backgroundColor = .secondarySystemBackground
            view.cornerRadius = 20
        }
        
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(inset: Margin.defaultValue)
        
        view.addSubview(profileView)
        profileView.anchorTopLeading()
        
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 10).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.addArrangedSubviews([individualAbleBtn, humankindAbleBtn])
        
        view.addSubview(tagsView)
        tagsView.topAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 4).isActive = true
        tagsView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2).isActive = true
        view.trailingAnchor.constraint(equalToSystemSpacingAfter: tagsView.trailingAnchor, multiplier: 2).isActive = true
        
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let partnerProfile = vm.partnerProfile {
            profileView.nameLabel.text = partnerProfile.name
            profileView.avatarView.image = partnerProfile.image
        }
    }
}

// MARK: Interaction
extension PlaceStoryVC: TagListViewDelegate {
    @objc private func individualAbleBtnTapped() {
        delegate?.placeStoryVCShouldStartIndividualAble(self, tag: selectedTag!)
    }
        
    @objc private func humankindAbleBtnTapped() {
        delegate?.placeStoryVCShouldHumankindAble(self, tag: selectedTag!)
    }
    
    @objc private func placePerspectivesTapped() {
        let vc = TagsVC(tagChoice_Sections: vm.tagChoice_Sections)
        vc.delegate = vm
        self.customPresentViewController(vc.presentr, viewController: UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    @objc func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        sender.tagViews.forEach {
            $0.isSelected = $0 === tagView
        }
        
        selectedTag = tagView.titleForNormal!
        let concept = Concept.map[selectedTag!]
        UIView.animate(withDuration: 0.25) {
            if self.selectedTag! == addtag {
                self.clearOperation()
                self.placePerspectivesTapped()
            } else if let concept = concept {
                self.configOperation(forConcept: concept)
            } else {
                self.configOperationForCondition()
            }
        }
    }
    
    private func clearOperation() {
        individualAbleBtn.isHidden = true
        humankindAbleBtn.isHidden = true
    }
        
    private func configOperationForCondition() {
        let individualAble = IndividualAble.Compare
        individualAbleBtn.setTitle(individualAble.rawValue, for: .normal)
        individualAbleBtn.isHidden = false
        
        humankindAbleBtn.isHidden = !allowsEditing
        if !humankindAbleBtn.isHidden {
            humankindAbleBtn.setTitle(individualAble.humankindAble.rawValue, for: .normal)
        }
    }
    
    private func configOperation(forConcept concept: Concept) {
        individualAbleBtn.isHidden = false
        individualAbleBtn.setTitle(concept.individualAble.rawValue, for: .normal)
        
        humankindAbleBtn.isHidden = concept.isPrivate || !allowsEditing
        if !humankindAbleBtn.isHidden {
            humankindAbleBtn.setTitle(concept.individualAble.humankindAble.rawValue, for: .normal)
        }
    }
}

private let addtag = "Add Tag"

extension Concept {
    var havingHumankindAble: Bool {
        !isPrivate
    }
}
