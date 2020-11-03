//
//  CommunityVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/4.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit

class CommunityVC: UIPageViewController {
    private let community: CommunityVM
    init(community community_: CommunityVM) {
        community = community_
        super.init(transitionStyle: .scroll, navigationOrientation: .vertical)
        
        setViewControllers([WordVC1(word: community.wordVMs.first!)], direction: .forward, animated: false, completion: nil)
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CommunityVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let wordVM = (viewController as! WordVC1).word as! CKWordVM
        let index = community.wordVMs.firstIndex {
            $0 === wordVM
        }!
        guard case let prevIndex = index - 1, prevIndex >= community.wordVMs.startIndex else {
            return nil
        }
        return WordVC1(word: community.wordVMs[community.wordVMs.index(index, offsetBy: -1)])
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let wordVM = (viewController as! WordVC1).word as! CKWordVM
        let index = community.wordVMs.firstIndex {
            $0 === wordVM
        }!
        guard case let nextIndx = index + 1, nextIndx < community.wordVMs.endIndex else {
            return nil
        }
        return WordVC1(word: community.wordVMs[community.wordVMs.index(index, offsetBy: 1)])
    }
}
