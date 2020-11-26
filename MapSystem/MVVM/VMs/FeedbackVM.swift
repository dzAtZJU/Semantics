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
    
    private var conditionRank_List: [ConditionRank]
    
    private var dataLayer: Realm!
    
    init(placeId placeId_: String, completion: @escaping (FeedbackVM) -> Void) {
        self.dataLayer = RealmSpace.main.privatRealm
        let publicDataLayer = RealmSpace.main.publicRealm
        
        self.targetPlace = publicDataLayer.queryPlace(_id: placeId_)
        self.conditionRank_List = self.dataLayer.queryConditionRank_List(havingPlace: placeId_)
        
        let items = self.conditionRank_List.filter {
            !$0.placeScore_List.contains {
                $0.placeID == placeId_
            }
        }
        
        guard !items.isEmpty else {
            completion(self)
            return
        }
        
        try! self.dataLayer.write {
            items.forEach {
                $0.placeScore_List.insert(PlaceScore(placeID: self.targetPlace._id, score: 0), at: 0)
            }
        }
        
        completion(self)
    }
    
    var count: Int {
        conditionRank_List.count
    }
    
    var firstConditionFeedbackVM: ConditionFeedbackVM {
        ConditionFeedbackVM(targetPlace: targetPlace, rankByCondition: conditionRank_List.first!)
    }
    
    func conditionFeedbackVM(after vm: ConditionFeedbackVM) -> ConditionFeedbackVM? {
        let index = conditionRank_List.firstIndex(of: vm.rankByCondition)!
        guard case let nextIndex = index + 1, nextIndex < conditionRank_List.endIndex else {
            return nil
        }
        return ConditionFeedbackVM(targetPlace: targetPlace, rankByCondition: conditionRank_List[nextIndex])
    }
    
    func conditionFeedbackVM(before vm: ConditionFeedbackVM) -> ConditionFeedbackVM? {
        let index = conditionRank_List.firstIndex(of: vm.rankByCondition)!
        guard case let preIndex = index - 1, preIndex >= conditionRank_List.startIndex
        else {
            return nil
        }
        return ConditionFeedbackVM(targetPlace: targetPlace, rankByCondition: conditionRank_List[preIndex])
    }
    
    func indexFor(conditionFeedbackVM: ConditionFeedbackVM) -> Int {
        return conditionRank_List.firstIndex(of: conditionFeedbackVM.rankByCondition)!
    }
}
