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
    let conditionTitle: String
    let privateDataLayer: Realm
    let publicDataLayer: Realm
    
    let targetPlace: Place
    let rankByCondition: ConditionRank
    init(targetPlace targetPlace_: Place, rankByCondition rankByCondition_: ConditionRank) {
        targetPlace = targetPlace_
        rankByCondition = rankByCondition_
        
        publicDataLayer = RealmSpace.main.publicRealm
        privateDataLayer = RealmSpace.main.privatRealm
        conditionTitle = rankByCondition.conditionID
    }
    
    var levels: Int {
        Set(rankByCondition.placeScore_List.map(by: \.score)).count
    }
    
    func count(ofLevel level: Int) -> Int {
        rankByCondition.placeScore_List.count {
            $0.score == level
        }
    }
    
    struct PlaceInfo {
        let title: String
        let isTargetPlace: Bool
    }
    
    func placeInfo(at: RankInfo) -> PlaceInfo {
        let bt = Date().timeIntervalSince1970
        let thisPlace = publicDataLayer.queryPlace(_id: placeScore(at: at).placeID)
        let et = Date().timeIntervalSince1970
        print("[Measure] queryPlace \(et-bt)")
        return PlaceInfo(title: thisPlace.title, isTargetPlace: thisPlace._id == targetPlace._id)
    }
    
    struct RankInfo {
        let level: Int
        let ordinal: Int
    }
    
    // -1 | 0 1 2 3 4 | 5
    func movePlace(at: RankInfo, to: RankInfo) {
        let atIndex = index(of: at)
        var toIndex: Int!
        switch to.level {
        case -1:
            toIndex = 0
        case levels:
            toIndex = rankByCondition.placeScore_List.count
        default:
            toIndex = index(of: to)
        }
        let isOnlyOne = at.level != to.level && count(ofLevel: at.level) == 1
        print("[movePlace] from: \(at)-\(atIndex) to: \(to)-\(toIndex!) isOnlyOne: \(isOnlyOne)")
        
        let atPlaceScore = self.placeScore(at: at)
        let newPlaceScore = PlaceScore(placeID: atPlaceScore.placeID, score: to.level)
        if atIndex < toIndex {
            toIndex -= 1
        }
        try! privateDataLayer.write {
            self.rankByCondition.placeScore_List.remove(at: atIndex)
            self.rankByCondition.placeScore_List.insert(newPlaceScore, at: toIndex)
            if isOnlyOne {
                var start = atIndex
                if toIndex < atIndex {
                    start += 1
                } else if toIndex == atIndex, to.level < at.level {
                    start += 1
                }
                for i in start..<self.rankByCondition.placeScore_List.endIndex {
                    self.rankByCondition.placeScore_List[i].score -= 1
                }
            }
            if to.level == -1 {
                for item in self.rankByCondition.placeScore_List {
                    item.score += 1
                }
            }
        }
        
        print("[ConditionFeedbackVM] scores \(rankByCondition.placeScore_List.map(by: \.score))")
    }
    
    private func placeScore(at rank: RankInfo) -> PlaceScore {
        rankByCondition.placeScore_List[index(of: rank)]
    }
    
    private func index(of rank: RankInfo) -> Int {
        let i = rankByCondition.placeScore_List.firstIndex {
            $0.score == rank.level
            }! + rank.ordinal
        print("[ConditionFeedbackVM] \(rank) -> \(i)")
        return i
    }
}
