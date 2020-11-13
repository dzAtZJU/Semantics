import UIKit
import Combine

struct Section {
    let titleItem: TitleItem
    let items: [TitleItem]
}

class ConceptVC: UIViewController {
    private let vm: ConceptVM
    
    var interpretationToken: AnyCancellable?
    
    private var inputingItem: TitleItem?
    
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
    <TitleItem, TitleItem> = {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, TitleItem> { cell, indexPath, titleItem in
            var content = UIListContentConfiguration.cell()
            content.textProperties.font = UIFont.preferredFont(forTextStyle: .title2)
            content.text = titleItem.title
            cell.contentConfiguration = content
        }
        let conceptCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, TitleItem> { cell, indexPath, titleItem in
            var content = ConceptContentConfiguration.inputing()
            content.placeholder = "input instance"
            content.textFieldDelegate = self
            cell.contentConfiguration = content
        }
        let tmp = UICollectionViewDiffableDataSource
        <TitleItem, TitleItem> (collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath,
             item: TitleItem) -> UICollectionViewCell? in
            if item.isInputing {
                return collectionView.dequeueConfiguredReusableCell(using: conceptCellRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using:
                      cellRegistration, for: indexPath, item: item)
            }
        }
        
        let titleRegistration = UICollectionView.SupplementaryRegistration
        <TitleSupplementaryView>(elementKind: TitleSupplementaryView.identifier) {
            supplementaryView, string, indexPath in
            let titleItem = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            supplementaryView.label.text = titleItem.title
        }
        let titleWithAddingRegistration = UICollectionView.SupplementaryRegistration
        <TitleWithAddingSupplementaryView>(elementKind: TitleWithAddingSupplementaryView.identifier) {
            supplementaryView, string, indexPath in
            let titleItem = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            supplementaryView.label.text = titleItem.title
            supplementaryView.addingBtnTapped = {
                supplementaryView.isUserInteractionEnabled = false
                var snapshot = NSDiffableDataSourceSectionSnapshot<TitleItem>()
                self.inputingItem = TitleItem(isInputing: true, title: "", type: nil)
                snapshot.append([self.inputingItem!])
                snapshot.append(self.dataSource.snapshot(for: titleItem).items)
                self.dataSource.apply(snapshot, to: titleItem)
            }
        }
        tmp.supplementaryViewProvider = {(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            let titleItem = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch titleItem.type! {
            case .Title:
                return collectionView.dequeueConfiguredReusableSupplementary(using: titleRegistration, for: indexPath)
            case .TitleWithAdding:
                return collectionView.dequeueConfiguredReusableSupplementary(using: titleWithAddingRegistration, for: indexPath)
            }
        }
        return tmp
    }()
        
    init(vm vm_: ConceptVM) {
        vm = vm_
        super.init(nibName: nil, bundle: nil)
        
        interpretationToken = vm.$conceptInterpretation.sink { newValue in
            let sections = self.vm.concept.map.map { (link, neighbors) -> Section in
                let headerType: HeaderType = link == .Instance ? .TitleWithAdding : .Title
                let sectionItem = TitleItem(isInputing: false, title: link.title, type: headerType)
                switch link {
                case .Instance:
                    return Section(titleItem: sectionItem, items: newValue!.instance.map({ TitleItem(isInputing: false, title: $0, type: nil) }))
                default:
                    return Section(titleItem: sectionItem, items: neighbors.map({ TitleItem(isInputing: false, title: $0.title, type: nil) }))
                }
            }
            var tmp = NSDiffableDataSourceSnapshot<TitleItem, TitleItem>()
            sections.forEach {
                tmp.appendSections([$0.titleItem])
                tmp.appendItems($0.items)
            }
            DispatchQueue.main.async {
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

