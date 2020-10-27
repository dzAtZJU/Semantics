import UIKit
import Kingfisher

private let HeaderElementKind = "HeaderElementKind"

class CountryHomeVC: UIViewController {
    private let vm: CountryHomeVM
    
    private var dataSource: UICollectionViewDiffableDataSource
        <TitleSection, ImageItem>!
    private var currentSnapshot: NSDiffableDataSourceSnapshot
        <TitleSection, ImageItem>!
    
    lazy var collectionView: UICollectionView = {
        let tmp = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        tmp.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: HeaderElementKind, withReuseIdentifier: TitleSupplementaryView.identifier)
        tmp.backgroundColor = .systemBackground
       return tmp
        
    }()
    
    init(vm vm_: CountryHomeVM) {
        vm = vm_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    override func viewDidLoad() {
        dataSource = UICollectionViewDiffableDataSource
            <TitleSection, ImageItem> (collectionView: collectionView) {
                (collectionView: UICollectionView, indexPath: IndexPath,
                item: ImageItem) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ImageCell.identifier,
                for: indexPath) as? ImageCell
                else {
                    fatalError("Cannot create new cell")
                }
            
            cell.imageView.kf.setImage(with: item.url)
            cell.titleLabel.text = item.title
            cell.subtitleLabel.text = item.subtitle
            return cell
        }
        dataSource.supplementaryViewProvider = { [weak self]
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let self = self, let snapshot = self.currentSnapshot else { return nil }
            
            if let titleSupplementary = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TitleSupplementaryView.identifier,
                for: indexPath) as? TitleSupplementaryView {

                let section = snapshot.sectionIdentifiers[indexPath.section]
                titleSupplementary.label.text = section.title
                return titleSupplementary
            } else {
                fatalError("Cannot create new supplementary")
            }
        }
        currentSnapshot = NSDiffableDataSourceSnapshot
            <TitleSection, ImageItem>()
        vm.sections.forEach {
            currentSnapshot.appendSections([TitleSection(title: $0.title)])
            currentSnapshot.appendItems($0.images)
        }
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}

extension CountryHomeVC {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard self.vm.sections[sectionIndex].count > 1 else {
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1)))
                let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95), heightDimension: .fractionalHeight(0.2)), subitems: [item])
                
                let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: titleSize,
                    elementKind: HeaderElementKind,
                    alignment: .top)
                
                let section = NSCollectionLayoutSection(group: horizontalGroup)
                section.boundarySupplementaryItems = [titleSupplementary]
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                return section
            }
            
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalHeight(0.5), heightDimension: .fractionalHeight(0.5)))
            let verticalGroup = NSCollectionLayoutGroup.vertical( layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .fractionalHeight(1.0)), subitem: item, count: 2)
            verticalGroup.interItemSpacing = .fixed(10)
            
            let containerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95),
                                                                                                       heightDimension: .fractionalHeight(0.4)), subitems: [verticalGroup])
            containerGroup.interItemSpacing = .fixed(10)
            
            let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(44))
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: titleSize,
                elementKind: HeaderElementKind,
                alignment: .top)
            
            let section = NSCollectionLayoutSection(group: containerGroup)
            section.boundarySupplementaryItems = [titleSupplementary]
            section.orthogonalScrollingBehavior = .groupPaging
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            return section
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20

        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        return layout
    }
}

private class TitleSupplementaryView: UICollectionReusableView {
    static let identifier = "TitleSupplementaryView"
    
    let label: UILabel = {
        let tmp = UILabel()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.adjustsFontForContentSizeCategory = true
        tmp.font = UIFont.preferredFont(forTextStyle: .title1)
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private class ImageCell: UICollectionViewCell {
    static let identifier = "ImageCell"
    
    let titleLabel: UILabel = {
        let tmp = UILabel()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.numberOfLines = 0
        tmp.font = UIFont.preferredFont(forTextStyle: .headline)
        return tmp
    }()
    
    let subtitleLabel: UILabel = {
        let tmp = UILabel()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.numberOfLines = 0
        tmp.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return tmp
    }()
    
    let imageView: UIImageView = {
        let tmp = UIImageView()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.cornerRadius = 4
        tmp.contentMode = .scaleAspectFill
        tmp.alpha = 0.8
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor),
            subtitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: subtitleLabel.bottomAnchor, multiplier: 1),
            subtitleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.7)
            ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct TitleSection: Hashable {
    let title: String
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
