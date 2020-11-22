import UIKit
import Combine

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

class ConceptVC: UIViewController {
    
    private let vm: ConceptVM
    
    var interpretationToken: AnyCancellable?
    
    private var inputingItem: ConceptItem?
    
    lazy var collectionView: UICollectionView = {
        let tmp = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.backgroundColor = .systemBackground
        return tmp
    }()
    
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
            let horizontal = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension:.fractionalWidth(1), heightDimension: .fractionalHeight(0.5)), subitem: item, count: 2)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(100)), subitem: horizontal, count: 2)
            
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
        let tmp = UICollectionViewDiffableDataSource
        <ConceptSectionInfo, ConceptItem> (collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath,
             item: ConceptItem) -> UICollectionViewCell? in
            switch item.itemType {
            case .Label(_):
                return collectionView.dequeueConfiguredReusableCell(using: labelCellRegistration, for: indexPath, item: item)
            case .AddingLabel:
                return collectionView.dequeueConfiguredReusableCell(using: textFieldCellRegistration, for: indexPath, item: item)
            case .Opinion(_):
                return collectionView.dequeueConfiguredReusableCell(using: labelCellRegistration, for: indexPath, item: item)
            case .AddingOpinion:
                return collectionView.dequeueConfiguredReusableCell(using: textFieldCellRegistration, for: indexPath, item: item)
            }
        }
        
        let titleHeaderRegistration = UICollectionView.SupplementaryRegistration
        <TitleSupplementaryView>(elementKind: TitleSupplementaryView.identifier) {
            supplementaryView, string, indexPath in
            let sectionInfo = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            guard case let HeaderType.Title(title) = sectionInfo.headerType else {
                fatalError()
            }

            supplementaryView.label.text = title
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
            case .Title:
                return collectionView.dequeueConfiguredReusableSupplementary(using: titleHeaderRegistration, for: indexPath)
            case .TitleWithAdding:
                return collectionView.dequeueConfiguredReusableSupplementary(using: titleWithAddingHeaderRegistration, for: indexPath)
            }
        }
        return tmp
    }()
        
    init(vm vm_: ConceptVM) {
        vm = vm_
        super.init(nibName: nil, bundle: nil)
        
        interpretationToken = vm.$sections.sink { newValue in
            DispatchQueue.main.async {
                var tmp = NSDiffableDataSourceSnapshot<ConceptSectionInfo, ConceptItem>()
                newValue!.forEach {
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
    }
}

extension ConceptVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else {
            return false
        }
        
        vm.addInstance(text, item: inputingItem!)
        textField.resignFirstResponder()
        return true
    }
}

