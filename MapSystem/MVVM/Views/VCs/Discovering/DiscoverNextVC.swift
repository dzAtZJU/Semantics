import UIKit
import Combine
import FloatingPanel

class DiscoverNextVC: UIViewController, PanelContent {
    var allowsEditing = true
    
    var prevPanelState:  FloatingPanelState?
    
    var panelContentDelegate: PanelContentDelegate!
    
    let showBackBtn = true
    
    private lazy var spinner = Spinner.create()
    
    private lazy var searchButton: UIButton = {
        let tmp = UIButton(systemName: "magnifyingglass.circle")
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.addTarget(self, action: #selector(searchBtnTapped), for: .touchUpInside)
        return tmp
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = .init(width: 100, height: 50)
        layout.sectionInsetReference = .fromContentInset
        let tmp = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.backgroundColor = .systemBackground
        tmp.dataSource = self
        tmp.delegate = self
        tmp.register(ConditionCell.self, forCellWithReuseIdentifier: ConditionCell.identifier)
        tmp.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: LabelSupplementaryView.self)
        return tmp
    }()
    
    private var collectionViewHeightConstraint: NSLayoutConstraint!
    
    let vm: DiscoverNextVM
    init(vm vm_: DiscoverNextVM) {
        vm = vm_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        view.addSubview(searchButton)
        view.trailingAnchor.constraint(equalToSystemSpacingAfter: searchButton.trailingAnchor, multiplier: 2).isActive = true
        
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalToSystemSpacingBelow: view.layoutMarginsGuide.topAnchor, multiplier: 1).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightConstraint.isActive = true
        searchButton.topAnchor.constraint(equalToSystemSpacingBelow: collectionView.bottomAnchor, multiplier: 2).isActive = true
        
        view.addSubview(spinner)
        spinner.anchorCenterSuperview()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = .init(width: collectionView.bounds.inset(by: collectionView.adjustedContentInset).width, height: 50)
        
        collectionViewHeightConstraint.constant = layout.collectionViewContentSize.height
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.panelContentDelegate.panel.move(to: .half, animated: false)
        }
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.panelContentDelegate.panel.move(to: .tip, animated: false)
        }
        super.viewWillDisappear(animated)
    }
}

extension DiscoverNextVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.conditionVMs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConditionCell.identifier, for: indexPath) as! ConditionCell
        cell.indexPath = indexPath
        
        let condition = vm.conditionVMs[indexPath.row]
        cell.label.text = condition.title
        cell.token = condition.$nextOperator.sink { newValue in
            DispatchQueue.main.async {
                if newValue.rawValue != cell.segmentedControl.selectedSegmentIndex {
                    cell.segmentedControl.selectedSegmentIndex = newValue.rawValue
                }
            }
        }
        cell.segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: LabelSupplementaryView.self, for: indexPath)
        header.label.text = "Overall"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! ConditionCell).cleanForDisappear()
    }
}

// MARK: Interation
extension DiscoverNextVC {
    @objc private func searchBtnTapped() {
        spinner.startAnimating()
        vm.runNextIteration { result in
            DispatchQueue.main.async {
                let vm = DiscoverdResultVM(result: result)
                let vc = DiscoverdResultVC(vm: vm)
                vc.panelContentDelegate = self.panelContentDelegate
                self.spinner.stopAnimating()
                self.show(vc, sender: nil)
            }
        }
    }
    
    @objc private func segmentedControlValueChanged(sender: UISegmentedControl) {
        let title = (sender.superview!.superview! as! ConditionCell).label.text!
        vm.modifyNextOperator(atTitle: title, value: sender.selectedSegmentIndex)
    }
}
