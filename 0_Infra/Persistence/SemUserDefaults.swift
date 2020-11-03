//
//  SemUserDefaults.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/9/1.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation

struct SemUserDefaults {
    static func setRealmPath(partitionValue: String, _ path: String) {
        var dic = getRealmPathDic()
        if dic == nil {
            dic = [String: String]()
        } else if dic![partitionValue] != nil {
            fatalError()
        }
        dic![partitionValue] = path
        UserDefaults.standard.set(dic!, forKey: "realm_backup")
    }
    
    static func clearRealmPath(partitionValue: String) {
        if var dic = getRealmPathDic() {
            dic[partitionValue] = nil
            UserDefaults.standard.set(dic, forKey: "realm_backup")
        }
    }
    
    static func getRealmPathDic() -> [String: String]? {
        UserDefaults.standard.dictionary(forKey: "realm_backup") as? [String: String]
    }
}
