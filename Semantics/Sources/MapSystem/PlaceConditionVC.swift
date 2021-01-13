//
//  PlaceConditionVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/9.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

struct Condition {
    enum `Type` {
        case bool
    }
    
    let title: String
    let subTitle = ""
    let caterogy = ""
    let type = Type.bool
    
    init(title: String) {
        self.title = title
    }
}

class ConditionsVM: NSObject {
    let conditions = [Condition(title: "卫生间"), Condition(title: "咖啡"), Condition(title: "空间感"), Condition(title: "小孩吵"), Condition(title: "背景音乐"), Condition(title: "网络")]
}

extension ConditionsVM: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        conditions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConditionsVC.cellIdentifier, for: indexPath) as! ConditionCell
        cell.label.text = conditions[indexPath.row].title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: LabelSupplementaryView.self, for: indexPath)
        header.label.text = "Overall"
        return header
    }
}

class ConditionsVC: UIViewController {
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
        tmp.dataSource = vm
        tmp.delegate = vm
        tmp.register(ConditionCell.self, forCellWithReuseIdentifier: Self.cellIdentifier)
        tmp.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: LabelSupplementaryView.self)
        return tmp
    }()
    
    private let vm: ConditionsVM
    init(vm vm_: ConditionsVM) {
        vm = vm_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(searchButton)
        view.trailingAnchor.constraint(equalToSystemSpacingAfter: searchButton.trailingAnchor, multiplier: 2).isActive = true
        searchButton.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 2).isActive = true
        collectionView.topAnchor.constraint(equalToSystemSpacingBelow: searchButton.bottomAnchor, multiplier: 1).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = .init(width: collectionView.bounds.inset(by: collectionView.adjustedContentInset).width, height: 50)
    }
}

// MARK: Interation
extension ConditionsVC {
    @objc private func searchBtnTapped() {
        
    }
}
