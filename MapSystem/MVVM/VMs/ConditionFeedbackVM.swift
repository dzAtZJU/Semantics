//
//  FeedbackVM.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/14.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import RealmSwift

class ConditionFeedbackVM {
    let rankByCondition: ConditionRank
    init(rankByCondition rankByCondition_: ConditionRank) {
        rankByCondition = rankByCondition_
    }
    
    var conditionTitle: String {
        rankByCondition.condition!.title
    }
        
    var levels: Int {
        Set(rankByCondition.placeScoreList.map(by: \.score)).count
    }
    
    func count(ofLevel level: Int) -> Int {
        rankByCondition.placeScoreList.count {
            $0.score == level
        }
    }
    
    func placeTitle(atLevel level: Int, ordinal: Int) -> String {
        let placeScores = rankByCondition.placeScoreList.filter {
            $0.score == level
        }
        let index = placeScores.index(placeScores.startIndex, offsetBy: ordinal)
        return placeScores[index].place!.title
    }
}
