//
//  DiscoverdResultVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/28.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import Combine

class DiscoverdResultVC: UIViewController, PanelContent {
    var panelContentVM: PanelContentVM! {
        nil
    }
    
    var panelContentDelegate: PanelContentDelegate!
       
    let showBackBtn = true
       
    let topInset = 0
    
    static let pageMargin: CGFloat = 50
    
    let vm: DiscoverdResultVM
    init(vm vm_: DiscoverdResultVM) {
        vm = vm_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var selectedAnnotationToken: AnyCancellable?
    
    private lazy var label: UILabel = {
         let tmp = UILabel()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.font = UIFont.preferredFont(forTextStyle: .title3)
        return tmp
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInsetReference = .fromContentInset
        let tmp = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.contentInset = .init(horizontal: Self.pageMargin, vertical: 0)
        tmp.backgroundColor = .systemYellow
        tmp.dataSource = self
        tmp.delegate = self
        tmp.register(ConditionBackerCell.self, forCellWithReuseIdentifier: ConditionBackerCell.identifier)
        return tmp
    }()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemYellow

        view.addSubview(label)
        label.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2).isActive = true
        label.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2).isActive = true
        
        view.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = vm.title()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        panelContentDelegate.mapVM.selectedAnnotationEventLock = true
        selectedAnnotationToken = panelContentDelegate.mapVM.$selectedAnnotationEvent.removeDuplicates(by: { (a, b) -> Bool in
            a.0 == b.0
        }).sink { newEvent in
            switch newEvent.1 {
            case .fromModel, .onlyMap:
                if newEvent.0 == nil {
                    self.panelContentDelegate.map.deselectAnnotation(nil, animated: true)
                }
            case .fromView:
                if let type = newEvent.0?.type, type != .inDiscovering {
                    break
                }
                self.vm.setPlaceId(newEvent.0?.placeId)
                self.collectionView.reloadData()
            }
        }
        panelContentDelegate.panel.move(to: .tip, animated: true)
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        panelContentDelegate.mapVM.removeAnnotations(type: .inDiscovering)
        panelContentDelegate.mapVM.selectedAnnotationEventLock = false
        selectedAnnotationToken = nil
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        panelContentDelegate.panel.move(to: .full, animated: true)
        super.viewDidDisappear(animated)
    }
}

extension DiscoverdResultVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let placeConditionsVM = vm.placeConditionsVM else {
            return 0
        }
        
        return placeConditionsVM.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let placeConditionsVM = vm.placeConditionsVM else {
            fatalError()
        }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConditionBackerCell.identifier, for: indexPath) as! ConditionBackerCell
        cell.indexPath = indexPath
        cell.label.text = placeConditionsVM.title(at: indexPath)
        cell.button.addTarget(self, action: #selector(dislikeBtnTapped), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.width - collectionView.contentInset.horizontal, height: 50)
    }
}

extension DiscoverdResultVC {
    @objc private func dislikeBtnTapped(sender: UIButton) {
        let indexPath = (sender.superview!.superview! as! ConditionBackerCell).indexPath!
        panelContentDelegate.setSpinning(true)
        vm.placeConditionsVM!.dislike(at: indexPath) {
            DispatchQueue.main.async {
                self.panelContentDelegate.setSpinning(false)
            }
        }
    }
}
