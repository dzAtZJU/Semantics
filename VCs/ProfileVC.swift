//
//  ProfileVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/8.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit


class ProfileVC: UIViewController {
    
    override func loadView() {
        view = UIView()
        tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "tortoise"), selectedImage: UIImage(systemName: "tortoise.fill"))
    }
}
