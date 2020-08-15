//
//  FeedbackVM.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/14.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import RealmSwift

class FeedbackVM {
    private let conditionsRank: List<ConditionRank>
    init(conditionsRank conditionsRank_: List<ConditionRank>) {
        conditionsRank = conditionsRank_
    }
    
    
    var firstConditionFeedbackVM: ConditionFeedbackVM {
        ConditionFeedbackVM(rankByCondition: conditionsRank.first!)
    }
    
    func conditionFeedbackVM(after vm: ConditionFeedbackVM) -> ConditionFeedbackVM? {
        let index = conditionsRank.index(of: vm.rankByCondition)!
        guard case let nextIndex = index + 1, nextIndex < conditionsRank.endIndex else {
            return nil
        }
        return ConditionFeedbackVM(rankByCondition: conditionsRank[nextIndex])
    }
    
    func conditionFeedbackVM(before vm: ConditionFeedbackVM) -> ConditionFeedbackVM? {
        let index = conditionsRank.index(of: vm.rankByCondition)!
        guard case let preIndex = index - 1, preIndex >= conditionsRank.startIndex
            else {
            return nil
        }
        return ConditionFeedbackVM(rankByCondition: conditionsRank[preIndex])
    }
}
