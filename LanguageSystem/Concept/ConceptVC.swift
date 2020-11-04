import UIKit

private let HeaderElementKind = "HeaderElementKind"

class ConceptVC: UIViewController {
    lazy var collectionView: UICollectionView = {
        let tmp = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.backgroundColor = .systemBackground
        return tmp
    }()
    
    private let vm: ConceptVM
    
    private lazy var dataSource: UICollectionViewDiffableDataSource
    <TitleItem, TitleItem> = {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, TitleItem> { cell, indexPath, titleItem in
            var content = UIListContentConfiguration.cell()
            content.textProperties.font = UIFont.preferredFont(forTextStyle: .title2)
            content.text = titleItem.title
            cell.contentConfiguration = content
        }
        let tmp = UICollectionViewDiffableDataSource
        <TitleItem, TitleItem> (collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath,
             item: TitleItem) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using:
                  cellRegistration, for: indexPath, item: item)
            
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration
            <TitleSupplementaryView>(elementKind: "HeaderElementKind") {
            supplementaryView, string, indexPath in
            let titleItem = self.currentSnapshot.sectionIdentifiers[indexPath.section]
            supplementaryView.label.text = titleItem.title
        }
        tmp.supplementaryViewProvider = { [weak self]
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        return tmp
    }()
    
    private lazy var currentSnapshot: NSDiffableDataSourceSnapshot<TitleItem, TitleItem> = {
        var tmp = NSDiffableDataSourceSnapshot
        <TitleItem, TitleItem>()
        self.vm.sections.forEach {
            tmp.appendSections([$0.titleItem])
            tmp.appendItems($0.items)
        }
        return tmp
    }()
    
    init(vm vm_: ConceptVM) {
        vm = vm_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
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
    
    override func viewDidLoad() {
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}

extension ConceptVC {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40)))
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(0)), subitems: [item])
            verticalGroup.interItemSpacing = .fixed(10)
            
            let section = NSCollectionLayoutSection(group: verticalGroup)
           
            
            let titleSize = NSCollectionLayoutSize(widthDimension:.fractionalWidth(1.0), heightDimension: .estimated(44))
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: titleSize,
                elementKind: HeaderElementKind,
                alignment: .top)
            
            section.boundarySupplementaryItems = [titleSupplementary]
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        return layout
    }
}

