//
//  OrganismVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/23.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import SwifterSwift

class OrganVC: SemSetsVC {
    private let imgView: UIImageView = {
        let tmp = UIImageView(image: UIImage(named: "mimosa_pudica"))
        tmp.contentMode = .scaleAspectFill
        tmp.clipsToBounds = true
        tmp.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return tmp
    }()
    
    init() {
        let oceanLayer = SectorDataLayer.shared.queryOrganSector().oceanLayers!.anyObject()! as! OceanLayer
        super.init(oceanLayer: oceanLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.insertSubview(imgView, at: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.frame = view.bounds
        
        if let sectorVC = parent?.parent as? UIPageViewController, let sectorsVC = sectorVC.parent as? UIPageViewController {
            let pan = UIPanGestureRecognizer()
            view.addGestureRecognizer(pan)
            let scrollView = sectorVC.view.subviews.first {
                $0 is UIScrollView
                } as! UIScrollView
            pan.require(toFail: scrollView.panGestureRecognizer)
            let nextScrollView = sectorsVC.view.subviews.first {
                $0 is UIScrollView
                } as! UIScrollView
            nextScrollView.panGestureRecognizer.require(toFail: pan)
        }
    }
}

