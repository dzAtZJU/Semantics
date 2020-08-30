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
    let dataLayer: SemWorldDataLayer
    
    let targetPlace: Place
    let rankByCondition: ConditionRank
    init(targetPlace targetPlace_: Place, rankByCondition rankByCondition_: ConditionRank) {
        targetPlace = targetPlace_
        rankByCondition = rankByCondition_
        
        dataLayer = SemWorldDataLayer(realm: RealmSpace.main.realm(partitionValue: RealmSpace.partitionValue))
        conditionTitle = dataLayer.queryCondition(_id: rankByCondition.conditionId!).title
    }
    
    var levels: Int {
        Set(rankByCondition.placeScoreList.map(by: \.score)).count
    }
    
    func count(ofLevel level: Int) -> Int {
        rankByCondition.placeScoreList.count {
            $0.score == level
        }
    }
    
    struct PlaceInfo {
        let title: String
        let isTargetPlace: Bool
    }
    
    func placeInfo(at: RankInfo) -> PlaceInfo {
        let bt = Date().timeIntervalSince1970
        let thisPlace = dataLayer.queryPlace(_id: placeScore(at: at).placeId!)
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
            toIndex = rankByCondition.placeScoreList.count - 1
        default:
            toIndex = index(of: to)
        }
        let isOnlyOne = at.level != to.level && count(ofLevel: at.level) == 1
        let placeScore = self.placeScore(at: at)
        
        try! dataLayer.realm.write {
            placeScore.score = to.level
            self.rankByCondition.placeScoreList.move(from: atIndex, to: toIndex)
            
            if isOnlyOne {
                let start = atIndex + (toIndex > atIndex ? 0 : 1)
                for i in start..<self.rankByCondition.placeScoreList.endIndex {
                    self.rankByCondition.placeScoreList[i].score -= 1
                }
            }
            if to.level == -1 {
                for item in self.rankByCondition.placeScoreList {
                    item.score += 1
                }
            }
        }
        
        print("[] scores \(rankByCondition.placeScoreList.map(by: \.score))")
    }
    
    private func placeScore(at rank: RankInfo) -> PlaceScore {
        rankByCondition.placeScoreList[index(of: rank)]
    }
    
    private func index(of rank: RankInfo) -> Int {
        var i = rankByCondition.placeScoreList.firstIndex {
            $0.score == rank.level
            }! + rank.ordinal
        if i == rankByCondition.placeScoreList.endIndex {
            i -= 1
        }
        return i
    }
}
