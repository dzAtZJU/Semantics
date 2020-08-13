//
//  SemWorldDataLayer.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/10.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import RealmSwift

class SemWorldDataLayer {
    private init() {}
    
    static let shared = SemWorldDataLayer()
    
    private lazy var publicRealm: Realm = {
        try! Realm(configuration: AccountLayer.shared.currentUser!.configuration(partitionValue: "Public"))
    }()
}

extension SemWorldDataLayer {
    func queryOrCreateCurrentIndividual(userName: String) -> Individual {
        let userID = AccountLayer.shared.currentUserID!
        var individual: Individual! = publicRealm.object(ofType: Individual.self, forPrimaryKey: userID)
        if individual == nil {
            individual = Individual(id: userID, title: KeychainItem.currentUserName)
            try! publicRealm.write {
                publicRealm.add(individual)
            }
        }
        return individual
    }
}

extension SemWorldDataLayer {
    func queryPlaces() -> Results<Place> {
        publicRealm.objects(Place.self)
    }
    
    func createMockData() {
        guard publicRealm.objects(Place.self).count == 0 else {
            return
        }
        
        let places = [Place(title: "Tims-上滨生活广场", latitude: 31.260_402, longitude: 121.503_985), Place(title: "Tims-大学路", latitude: 31.304_107, longitude: 121.508_546)]
        try! publicRealm.write {
            publicRealm.add(places)
        }
    }
}
