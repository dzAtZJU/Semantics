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
    private var targetPlace: Place!
    private var conditionsRank: List<ConditionRank>!
    private var dataLayer: SemWorldDataLayer!
    init(placeId placeId_: String, completion: @escaping (FeedbackVM) -> Void) {
        RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!) {
            self.dataLayer = SemWorldDataLayer(realm: $0)
            
            RealmSpace.main.realm(RealmSpace.partitionValue) {
                let publicDataLayer = SemWorldDataLayer(realm: $0)
                
                self.dataLayer.createExtraConditionRanks(allConditionIds: publicDataLayer.queryConditions())
                
                self.targetPlace = publicDataLayer.queryPlace(_id: placeId_)
                self.conditionsRank = self.dataLayer.queryCurrentIndividual()!.conditionsRank
                
                let items = self.conditionsRank.filter {
                    !$0.placeScoreList.contains {
                        $0.placeId == placeId_
                    }
                }
                
                guard !items.isEmpty else {
                    completion(self)
                    return
                }
                
                try! self.dataLayer.realm.write {
                    items.forEach {
                        $0.placeScoreList.insert(PlaceScore(conditionId: $0.conditionId, placeId: self.targetPlace._id, score: 0), at: 0)
                    }
                }
                
                completion(self)
            }
        }
    }
    
    var count: Int {
        conditionsRank.count
    }
    
    var firstConditionFeedbackVM: ConditionFeedbackVM {
        ConditionFeedbackVM(targetPlace: targetPlace, rankByCondition: conditionsRank.first!)
    }
    
    func conditionFeedbackVM(after vm: ConditionFeedbackVM) -> ConditionFeedbackVM? {
        let index = conditionsRank.index(of: vm.rankByCondition)!
        guard case let nextIndex = index + 1, nextIndex < conditionsRank.endIndex else {
            return nil
        }
        return ConditionFeedbackVM(targetPlace: targetPlace, rankByCondition: conditionsRank[nextIndex])
    }
    
    func conditionFeedbackVM(before vm: ConditionFeedbackVM) -> ConditionFeedbackVM? {
        let index = conditionsRank.index(of: vm.rankByCondition)!
        guard case let preIndex = index - 1, preIndex >= conditionsRank.startIndex
            else {
                return nil
        }
        return ConditionFeedbackVM(targetPlace: targetPlace, rankByCondition: conditionsRank[preIndex])
    }
}
