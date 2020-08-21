//
//  DiscoverNextVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/9.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import Combine

class DiscoverNextVC: UIViewController, PanelContent {
    var panelContentDelegate: PanelContentDelegate?
    
    let showBackBtn = false
    
    static let cellIdentifier = "cell"
    static let pageMargin: CGFloat = 50
    
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
        tmp.contentInset = .init(horizontal: Self.pageMargin, vertical: 0)
        tmp.backgroundColor = .systemBackground
        tmp.dataSource = self
        tmp.delegate = self
        tmp.register(ConditionCell.self, forCellWithReuseIdentifier: Self.cellIdentifier)
        tmp.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: LabelSupplementaryView.self)
        return tmp
    }()
    
    private let vm: DiscoverNextVM
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
        searchButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalToSystemSpacingBelow: searchButton.bottomAnchor, multiplier: 1).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = .init(width: collectionView.bounds.inset(by: collectionView.adjustedContentInset).width, height: 50)
    }
}

extension DiscoverNextVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.conditionVMs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiscoverNextVC.cellIdentifier, for: indexPath) as! ConditionCell
        cell.indexPath = indexPath
        
        let condition = vm.conditionVMs[indexPath.row]
        cell.label.text = condition.title
        cell.token = condition.$nextOperator.sink {
            if $0.rawValue != cell.segmentedControl.selectedSegmentIndex {
                cell.segmentedControl.selectedSegmentIndex = $0.rawValue
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
        print("didEndDisplaying \(cell)")
        (cell as! ConditionCell).cleanForDisappear()
    }
}

// MARK: Interation
extension DiscoverNextVC {
    @objc private func searchBtnTapped() {
        vm.runNextIteration()
    }
    
    @objc private func segmentedControlValueChanged(sender: UISegmentedControl) {
        let title = (sender.superview! as! ConditionCell).label.text!
        vm.modifyNextOperator(atTitle: title, value: sender.selectedSegmentIndex)
    }
}
