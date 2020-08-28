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
    let targetPlace: Place
    let rankByCondition: ConditionRank
    init(targetPlace targetPlace_: Place, rankByCondition rankByCondition_: ConditionRank) {
        targetPlace = targetPlace_
        rankByCondition = rankByCondition_
    }
    
    var conditionTitle: String {
        SemWorldDataLayer(realm: RealmSpace.main.newRealm()).queryCondition(_id: rankByCondition.conditionId!).title
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
        let thisPlace = SemWorldDataLayer(realm: RealmSpace.main.newRealm()).queryPlace(_id: placeScore(at: at).placeId!)
        return PlaceInfo(title: thisPlace.title, isTargetPlace: thisPlace._id == targetPlace._id)
    }
    
    struct RankInfo {
        let level: Int
        let ordinal: Int
    }
    
    // -1 | 0 1 2 3 4 | 5
    func movePlace(at: RankInfo, to: RankInfo, completion: @escaping () -> Void) {
        let placeScore = self.placeScore(at: at)
        RealmSpace.shared.async {
            let dataLayer = SemWorldDataLayer(partitionValue: RealmSpace.partitionValue)
            let livePlaceScore = dataLayer.queryPlaceSocre(_id: placeScore._id)
            let liveRankByCondition = dataLayer.queryConditionRank(_id: self.rankByCondition._id)
            if to.level != -1 {
                try! dataLayer.realm.write {
                    livePlaceScore.score = to.level
                    liveRankByCondition.placeScoreList.sort(by: \.score)
                }
            } else {
                try! dataLayer.realm.write {
                    for ps in liveRankByCondition.placeScoreList {
                        ps.score += 1
                    }
                    livePlaceScore.score = 0
                    liveRankByCondition.placeScoreList.sort(by: \.score)
                }
            }
            completion()
        }
    }
    
    private func placeScore(at: RankInfo) -> PlaceScore {
        let placeScores = rankByCondition.placeScoreList.filter {
            $0.score == at.level
        }
        let index = placeScores.index(placeScores.startIndex, offsetBy: at.ordinal)
        return placeScores[index]
    }
}
