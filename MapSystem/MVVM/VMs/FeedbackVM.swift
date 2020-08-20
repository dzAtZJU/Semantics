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
    init(placeId placeId_: ObjectId, completion: @escaping (FeedbackVM) -> Void) {
        RealmSpace.shared.async {
            self.dataLayer = SemWorldDataLayer(partitionValue: RealmSpace.partitionValue)
            self.targetPlace = self.dataLayer.queryPlaces(_ids: [placeId_]).first!
            self.conditionsRank = self.dataLayer.queryCurrentIndividual()!.conditionsRank
            
            for conditionRank in self.conditionsRank {
                let index = conditionRank.placeScoreList.firstIndex {
                    $0.place!._id == self.targetPlace._id
                }
                if index == nil {
                    try! self.dataLayer.realm.write {
                        conditionRank.placeScoreList.append(PlaceScore(place: self.targetPlace, score: 0))
                    }
                }
            }
            
            self.targetPlace = self.targetPlace.freeze()
            self.conditionsRank = self.conditionsRank.freeze()
            
            completion(self)
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
