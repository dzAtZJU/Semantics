import UIKit
import Combine
import FloatingPanel

struct ConceptSection {
    let sectionInfo: ConceptSectionInfo
    let items: [ConceptItem]
}

struct ConceptSectionInfo: Hashable, Equatable {
    let headerType: HeaderType
    
    let addingItemType: ItemType
    
    let uuid = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    static func == (lhs: ConceptSectionInfo, rhs: ConceptSectionInfo) -> Bool {
        lhs.uuid == rhs.uuid
    }
}

struct ConceptItem: Hashable, Equatable {
    let itemType: ItemType
    
    let uuid = UUID()
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    static func == (lhs: ConceptItem, rhs: ConceptItem) -> Bool {
        lhs.uuid == rhs.uuid
    }
}

enum ItemType {
    case Opinion(Opinion)
    case AddingOpinion
    
    case Label(String)
    case AddingLabel
}

enum HeaderType {
    case Title(String)
    case TitleWithAdding(String)
}

protocol AConceptVM: HavingOwner {
    var concept: Concept { get }
    
    var sectionsPublisher: Published<[ConceptSection]?>.Publisher { get }
        
    func addItem(_ item: ConceptItem)
}

class ConceptVC: UIViewController {
    
    private let vm: AConceptVM
    
    var interpretationToken: AnyCancellable?
    
    private var inputingItem: ConceptItem?
    
    lazy var spinner = Spinner.create()
    
    lazy var collectionView: UICollectionView = {
        let tmp = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.backgroundColor = .systemBackground
        tmp.showsVerticalScrollIndicator = false
        tmp.showsHorizontalScrollIndicator = false
        tmp.delegate = self
        return tmp
    }()
    
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
            let horizontal = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension:.fractionalWidth(1), heightDimension: .fractionalHeight(0.5)), subitem: item, count: 2)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(400)), subitem: horizontal, count: 2)
            
            let section = NSCollectionLayoutSection(group: verticalGroup)
            
            let titleSize = NSCollectionLayoutSize(widthDimension:.fractionalWidth(1.0), heightDimension: .estimated(44))
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: titleSize,
                elementKind: TitleSupplementaryView.identifier,
                alignment: .top)
            let titleWithAddingSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: titleSize,
                elementKind: TitleWithAddingSupplementaryView.identifier,
                alignment: .top)
            
            section.boundarySupplementaryItems = [titleSupplementary, titleWithAddingSupplementary]
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        return layout
    }
    
    private lazy var dataSource: UICollectionViewDiffableDataSource
    <ConceptSectionInfo, ConceptItem> = {
        let labelCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ConceptItem> { cell, indexPath, conceptItem in
            var content = UIListContentConfiguration.cell()
            content.textProperties.font = UIFont.preferredFont(forTextStyle: .title2)
            guard case let ItemType.Label(text) = conceptItem.itemType else {
                fatalError()
            }
            content.text = text
            cell.contentConfiguration = content
        }
        let textFieldCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ConceptItem> { cell, indexPath, titleItem in
            var content = ConceptContentConfiguration.inputing()
            content.placeholder = "input"
            content.textFieldDelegate = self
            cell.contentConfiguration = content
        }
        let pollCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ConceptItem> { cell, indexPath, conceptItem in
            guard case let ItemType.Opinion(opinion) = conceptItem.itemType else {
                fatalError()
            }
            var content = PollContentConfiguration(opinion: opinion)
            cell.contentConfiguration = content
        }
        let individualOpinionCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ConceptItem> { cell, indexPath, conceptItem in
            guard case let ItemType.Opinion(opinion) = conceptItem.itemType else {
                fatalError()
            }
            var content = IndividualOpinionContentConfiguration(opinion: opinion)
            cell.contentConfiguration = content
        }
        let addingPollViewCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ConceptItem> { cell, indexPath, conceptItem in
            guard case let ItemType.AddingOpinion = conceptItem.itemType else {
                fatalError()
            }
            let content = AddingPollViewContentConfiguration { (title, portion, url) in
                self.vm.addItem(
                    ConceptItem(itemType: .Opinion(Opinion(title: title, format: .Poll, data: try! JSONEncoder().encode(Opinion.Poll(agreePortion: portion, url: url)))))
                )
            }
            cell.contentConfiguration = content
        }
        let tmp = UICollectionViewDiffableDataSource
        <ConceptSectionInfo, ConceptItem> (collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath,
             item: ConceptItem) -> UICollectionViewCell? in
            switch item.itemType {
            case .Label(_):
                return collectionView.dequeueConfiguredReusableCell(using: labelCellRegistration, for: indexPath, item: item)
            case .AddingLabel:
                return collectionView.dequeueConfiguredReusableCell(using: textFieldCellRegistration, for: indexPath, item: item)
            case let .Opinion(opinion):
                switch opinion.format {
                case .Poll:
                    return collectionView.dequeueConfiguredReusableCell(using: pollCellRegistration, for: indexPath, item: item)
                case .Personal:
                    return collectionView.dequeueConfiguredReusableCell(using: individualOpinionCellRegistration, for: indexPath, item: item)
                }
            case .AddingOpinion:
                return collectionView.dequeueConfiguredReusableCell(using: addingPollViewCellRegistration, for: indexPath, item: item)
            }
        }
        
        let titleHeaderRegistration = UICollectionView.SupplementaryRegistration
        <TitleSupplementaryView>(elementKind: TitleSupplementaryView.identifier) {
            supplementaryView, string, indexPath in
            let sectionInfo = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch sectionInfo.headerType {
            case let .Title(text):
                fallthrough
            case let .TitleWithAdding(text):
                supplementaryView.label.text = text
            }
        }
        let titleWithAddingHeaderRegistration = UICollectionView.SupplementaryRegistration
        <TitleWithAddingSupplementaryView>(elementKind: TitleWithAddingSupplementaryView.identifier) {
            supplementaryView, string, indexPath in
            let sectionInfo = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            guard case let HeaderType.TitleWithAdding(title) = sectionInfo.headerType else {
                fatalError()
            }
            supplementaryView.label.text = title
            supplementaryView.addingBtnTapped = {
                supplementaryView.isUserInteractionEnabled = false
                var snapshot = NSDiffableDataSourceSectionSnapshot<ConceptItem>()
                self.inputingItem = ConceptItem(itemType: sectionInfo.addingItemType)
                snapshot.append([self.inputingItem!])
                snapshot.append(self.dataSource.snapshot(for: sectionInfo).items)
                self.dataSource.apply(snapshot, to: sectionInfo)
            }
        }
        tmp.supplementaryViewProvider = {(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let sectionInfo = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch sectionInfo.headerType {
            case .TitleWithAdding:
                if self.vm.allowsEditng {
                    return collectionView.dequeueConfiguredReusableSupplementary(using: titleWithAddingHeaderRegistration, for: indexPath)
                } else {
                    fallthrough
                }
            case .Title:
                return collectionView.dequeueConfiguredReusableSupplementary(using: titleHeaderRegistration, for: indexPath)
            }
        }
        return tmp
    }()
        
    init(vm vm_: AConceptVM) {
        vm = vm_
        super.init(nibName: nil, bundle: nil)
        
        interpretationToken = vm.sectionsPublisher.sink {
            guard let newValue = $0 else {
                return
            }
            DispatchQueue.main.async {
                var tmp = NSDiffableDataSourceSnapshot<ConceptSectionInfo, ConceptItem>()
                newValue.forEach {
                    tmp.appendSections([$0.sectionInfo])
                    tmp.appendItems($0.items)
                }
                self.dataSource.apply(tmp)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        title = vm.concept.title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(spinner)
        spinner.anchorCenterSuperview()
    }
}

extension ConceptVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)!
        switch item.itemType {
        case let .Opinion(opinion):
            switch opinion.format {
            case .Poll:
                spinner.startAnimating()
                let vc = WebViewController(nibName: nil, bundle: nil)
                let source = (opinion.opinionData as! Opinion.Poll).url
                vc.load(url: source) {
                    self.spinner.stopAnimating()
                    self.present(vc, animated: true, completion: nil)
                }
            default:
                return
            }
        default:
            return
        }
    }
}

extension ConceptVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else {
            return false
        }
        
        vm.addItem(ConceptItem(itemType: .Label(text)))
        textField.resignFirstResponder()
        return true
    }
}

