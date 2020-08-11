//
//  ConditionsVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/9.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import Combine

class ConditionVM {
    enum NextOperator: Int {
        case better = 0
        case noWorse
        case noMatter
    }
    
    enum `Type` {
        case bool
    }
    let subTitle = ""
    let caterogy = ""
    let type = Type.bool
    
    @Published private(set) var nextOperator: NextOperator = .noMatter
    
    let title: String
    init(title: String) {
        self.title = title
    }
    
    func setNextOperator(value: NextOperator) {
        if nextOperator != value {
            nextOperator = value
        }
    }
    
    func resetNextOperator() {
        if nextOperator != .noMatter {
            nextOperator = .noWorse
        }
    }
}

class ConditionsVM {
    let conditions = [ConditionVM(title: "卫生间"), ConditionVM(title: "咖啡"), ConditionVM(title: "空间感"), ConditionVM(title: "小孩吵"), ConditionVM(title: "背景音乐"), ConditionVM(title: "网络")]
    
    func modifyNextOperator(atTitle title: String, value: Int) {
        let condition = conditions.first {
            $0.title == title
            }!
        condition.setNextOperator(value: ConditionVM.NextOperator(rawValue: value)!)
    }
    
    func runNextIteration() {
        let filters = conditions.map {
            "\($0.title): \($0.nextOperator.rawValue)"
        }.joined(separator: ",")
        print("runNextIteration: \(filters)")
        conditions.forEach {
            $0.resetNextOperator()
        }
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
        tmp.dataSource = self
        tmp.delegate = self
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

extension ConditionsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.conditions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConditionsVC.cellIdentifier, for: indexPath) as! ConditionCell
        cell.indexPath = indexPath
        
        let condition = vm.conditions[indexPath.row]
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
extension ConditionsVC {
    @objc private func searchBtnTapped() {
        vm.runNextIteration()
    }
    
    @objc private func segmentedControlValueChanged(sender: UISegmentedControl) {
        let title = (sender.superview! as! ConditionCell).label.text!
        vm.modifyNextOperator(atTitle: title, value: sender.selectedSegmentIndex)
    }
}
