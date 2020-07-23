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
    
    override func loadView() {
        view = UIView()
        
        view.addSubview(imgView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.frame = view.bounds
    }
}

