import UIKit
import Combine
import TagListView
import Presentr
import FloatingPanel

protocol PlaceVCDelegate {
    func placeVCShouldStartIndividualAble(_ placeVC: PlaceVC, tag: String)
    
    func placeVCShouldHumankindAble(_ placeVC: PlaceVC, tag: String)
    
    func placeWillDisappear(_ placeVC: PlaceVC)
}

class PlaceVC: UIViewController, PanelContent {
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
    
    var vm: PlaceVM! {
        didSet {
            tagsToken = vm.$tags.sink {
                var perspectives = $0 ?? []
                perspectives.append(addtag)
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
    
    let showBackBtn = true
    
    var delegate: PlaceVCDelegate?
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
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
        
        profileView.nameLabel.text = "Mila"
        profileView.avatarView.image = UIImage(named: "mila")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.placeWillDisappear(self)
    }
}

// MARK: Interaction
extension PlaceVC: TagListViewDelegate {
    @objc private func individualAbleBtnTapped() {
        delegate?.placeVCShouldStartIndividualAble(self, tag: selectedTag!)
    }
        
    @objc private func humankindAbleBtnTapped() {
        delegate?.placeVCShouldHumankindAble(self, tag: selectedTag!)
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
        UIView.animate(withDuration: 0.25) {
            switch self.selectedTag! {
            case addtag:
                self.placePerspectivesTapped()
            case Concept.Seasons.title, Concept.Trust.title:
                self.individualAbleBtn.setTitle("Describe", for: .normal)
                self.humankindAbleBtn.setTitle("Talks", for: .normal)
                self.individualAbleBtn.isHidden = false
                self.humankindAbleBtn.isHidden = false
            case Concept.Scent.title:
                self.individualAbleBtn.setTitle("Experience", for: .normal)
                self.individualAbleBtn.isHidden = false
                self.humankindAbleBtn.isHidden = true
            default:
                self.individualAbleBtn.setTitle("Compare", for: .normal)
                self.humankindAbleBtn.setTitle("Search", for: .normal)
                self.individualAbleBtn.isHidden = false
                self.humankindAbleBtn.isHidden = false
            }
        }
    }
}

private let addtag = "add tag"
