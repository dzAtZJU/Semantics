//
//  BarrierVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/18.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class BarrierVC: UIViewController {
    private let imgView: UIImageView = {
        let tmp = UIImageView(image: UIImage(named: "rainbow"))
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
        imgView.frame = view.bounds
    }
}
