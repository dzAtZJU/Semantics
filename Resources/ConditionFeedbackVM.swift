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
    let privateDataLayer: SemWorldDataLayer
    let publicDataLayer: SemWorldDataLayer
    
    let targetPlace: Place
    let rankByCondition: ConditionRank
    init(targetPlace targetPlace_: Place, rankByCondition rankByCondition_: ConditionRank) {
        targetPlace = targetPlace_
        rankByCondition = rankByCondition_
        
        publicDataLayer = SemWorldDataLayer(realm: RealmSpace.main.realm(partitionValue1: RealmSpace.partitionValue))
        privateDataLayer = SemWorldDataLayer(realm: RealmSpace.main.realm(partitionValue1: RealmSpace.shared.queryCurrentUserID()!))
        conditionTitle = publicDataLayer.queryCondition(_id: rankByCondition.conditionId!).title
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
        let thisPlace = publicDataLayer.queryPlace(_id: placeScore(at: at).placeId!)
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
            toIndex = rankByCondition.placeScoreList.count
        default:
            toIndex = index(of: to)
        }
        let isOnlyOne = at.level != to.level && count(ofLevel: at.level) == 1
        print("[movePlace] from: \(at)-\(atIndex) to: \(to)-\(toIndex!) isOnlyOne: \(isOnlyOne)")
        
        let placeScore = self.placeScore(at: at)
        try! privateDataLayer.realm.write {
            placeScore.score = to.level
           let newPS = PlaceScore(placeId: placeScore.placeId!, score: placeScore.score)
            if atIndex < toIndex {
//                if toIndex == self.rankByCondition.placeScoreList.endIndex {
//                    self.rankByCondition.placeScoreList.append(newPS)
//                } else {
                    self.rankByCondition.placeScoreList.insert(newPS, at: toIndex)
//                }
                self.rankByCondition.placeScoreList.remove(at: atIndex)
            } else  if atIndex > toIndex {
                self.rankByCondition.placeScoreList.remove(at: atIndex)
//                if toIndex == self.rankByCondition.placeScoreList.endIndex {
//                    self.rankByCondition.placeScoreList.append(newPS)
//                } else {
                    self.rankByCondition.placeScoreList.insert(newPS, at: toIndex)
//                }
            }
            
            if isOnlyOne {
                var start = atIndex
                if toIndex < atIndex {
                    start += 1
                } else if toIndex == atIndex, to.level < at.level {
                    start += 1
                }
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
        
        print("[ConditionFeedbackVM] scores \(rankByCondition.placeScoreList.map(by: \.score))")
    }
    
    private func placeScore(at rank: RankInfo) -> PlaceScore {
        rankByCondition.placeScoreList[index(of: rank)]
    }
    
    private func index(of rank: RankInfo) -> Int {
        var i = rankByCondition.placeScoreList.firstIndex {
            $0.score == rank.level
            }! + rank.ordinal
        print("[ConditionFeedbackVM] \(rank) -> \(i)")
        return i
    }
}
