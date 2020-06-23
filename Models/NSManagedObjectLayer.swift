//
//  NSManagedObjectLayer.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/21.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

extension Word {
    var neighborWordsName: [String] {
        if let links = links {
            return  links.map {
                let link = $0 as! Link
                let neighborWord = link.words!.first {
                    $0 as AnyObject !== self
                    }!
                return (neighborWord as! Word).name!
            }
        }
        
        return []
    }
}
