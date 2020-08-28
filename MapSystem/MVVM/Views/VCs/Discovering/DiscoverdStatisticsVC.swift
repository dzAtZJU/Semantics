//
//  DiscoverdResultVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/28.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class DiscoverdResultVC: UIViewController, PanelContent {
    var panelContentVM: PanelContentVM! {
        nil
    }
    
    var panelContentDelegate: PanelContentDelegate!
       
    let showBackBtn = true
       
    let topInset = 0
    
    let vm: DiscoverdResultVM
    init(vm vm_: DiscoverdResultVM) {
        vm = vm_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var label: UILabel = {
         let tmp = UILabel()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.font = UIFont.preferredFont(forTextStyle: .title3)
        return tmp
    }()
    
    override func loadView() {
        view = UIView()

        view.addSubview(label)
        label.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1).isActive = true
        label.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2).isActive = true
    }
    
    
    override func viewDidLoad() {
        label.text = "\(vm.count) places founded"
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            panelContentDelegate.mapVM.removeAnnotations(type: .inDiscovering)
        }
        super.didMove(toParent: parent)
    }
}
