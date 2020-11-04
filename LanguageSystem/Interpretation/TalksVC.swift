import UIKit
import Kingfisher

private let HeaderElementKind = "HeaderElementKind"
private let BackgroundElementKind = "BackgroundElementKind"

class TalksVC: UIViewController {
    lazy var collectionView: UICollectionView = {
        let tmp = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.backgroundColor = .systemBackground
        return tmp
    }()
    
    var layout: UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(0)))
            
            let itemCount = self.vm.sections[sectionIndex].items.count > 1 ? 2 : 1
            let estimatedItmeHeight = 130
            let estimatedGroupHeight = CGFloat(itemCount * estimatedItmeHeight)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(estimatedGroupHeight)), subitem: item, count: itemCount)
            verticalGroup.interItemSpacing = .fixed(10)
            
            let section = NSCollectionLayoutSection(group: verticalGroup)
            section.interGroupSpacing = 10
            
            let titleSize = NSCollectionLayoutSize(widthDimension:.fractionalWidth(1.0), heightDimension: .estimated(44))
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: titleSize,
                elementKind: HeaderElementKind,
                alignment: .top)
            section.boundarySupplementaryItems = [titleSupplementary]
            
            let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: BackgroundElementKind)
            section.decorationItems = [backgroundItem]
            
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        layout.register(SeparatorSupplementaryView.self, forDecorationViewOfKind: BackgroundElementKind)
        return layout
    }
    
    private let vm: TalksVM
    
    private lazy var dataSource: UICollectionViewDiffableDataSource
    <TitleItem, IntepretationBirdItem> = {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, IntepretationBirdItem> { cell, indexPath, intepretationBirdItem in
            let v = InterpretationBirdView()
            v.avatarWithNameView.nameLabel.text = intepretationBirdItem.avatarWithName.title
            v.avatarWithNameView.avatarView.kf.setImage(with: intepretationBirdItem.avatarWithName.url)
            v.setContentSources(intepretationBirdItem.contentSources)
            cell.contentView.addSubview(v)
            v.fillToSuperview()
        }
        let tmp = UICollectionViewDiffableDataSource
        <TitleItem, IntepretationBirdItem> (collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath,
             item: IntepretationBirdItem) -> UICollectionViewCell? in
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
    
    private lazy var currentSnapshot: NSDiffableDataSourceSnapshot<TitleItem, IntepretationBirdItem> = {
        var tmp = NSDiffableDataSourceSnapshot
        <TitleItem, IntepretationBirdItem>()
        self.vm.sections.forEach {
            tmp.appendSections([$0.titleItem])
            tmp.appendItems($0.items)
        }
        return tmp
    }()
    
    init(vm vm_: TalksVM) {
        vm = vm_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        title = vm.placeID
        
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
