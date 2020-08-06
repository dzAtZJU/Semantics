//
//  BarrierVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import SwifterSwift

class BarrierVC: UIViewController {
    private let imgView: UIImageView = {
        let tmp = UIImageView(image: UIImage(named: "rainbow"))
        tmp.contentMode = .scaleAspectFill
        tmp.clipsToBounds = true
        tmp.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return tmp
    }()
    
    private lazy var deleteButton: UIButton = {
        let tmp = UIButton()
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.setImage(UIImage(systemName: "trash"), for: .normal)
        tmp.setTitle("Delete Sector", for: .normal)
        tmp.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return tmp
    }()
    
    override func loadView() {
        view = UIView()
        
        view.addSubview(imgView)
        
        view.addSubview(deleteButton)
        deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        deleteButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
    }
    
    override func viewDidLoad() {
        imgView.frame = view.bounds
        
        let pan = UIPanGestureRecognizer()
        view.addGestureRecognizer(pan)
        if let parent = parent as? UIPageViewController {
            let scrollView = parent.view.subviews.first {
                               $0 is UIScrollView
                               } as! UIScrollView
            pan.require(toFail: scrollView.panGestureRecognizer)
            if let nextParent = parent.parent as? UIPageViewController {
                let scrollView = nextParent.view.subviews.first {
                    $0 is UIScrollView
                    } as! UIScrollView
                scrollView.panGestureRecognizer.require(toFail: pan)
            }
        }
    }
}

extension BarrierVC {
    @objc func deleteButtonTapped() {
        guard let sectorVC = parent as? SemSectorVC else {
            return
        }
        
        appManagedObjectContext.delete(sectorVC.sector)
    }
}
