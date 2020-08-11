//
//  SemWorldDataLayer.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/10.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import RealmSwift

struct SemWorldDataLayer {
    private static let teamID = UUID().uuidString
    private static let app = RealmApp(id: "semantics-tonbj")
    
    private static var publicRealm: Realm!
    
    private static var realm: Realm!

    private static var userID: String {
        app.currentUser()!.identity!
    }
    
    static func login(userName: String, completion: @escaping () -> Void) {
        app.login(withCredential: AppCredentials(appleToken: userName)) { (user, error) in
            guard error == nil else {
                fatalError("\(error)")
            }
            print("identity \(app.currentUser()!.identity)")
        }
        
//        app.login(withCredential: AppCredentials.anonymous()) { (_, error) in
//            guard error == nil else {
//                fatalError()
//            }
//            print("identity \(app.currentUser()!.identity)")
//            loadRealms(userName: userName)
//            completion()
//        }
    }
    
    static func loadRealms(userName: String = "") {
        publicRealm = try! Realm(configuration: app.currentUser()!.configuration(partitionValue: "Public"))
        
        let individual = queryOrCreateCurrentIndividual(userName: userName)
        
        print("individual \(individual.id) \(individual.title)")
    }
    
    private static func queryOrCreateCurrentIndividual(userName: String) -> Individual {
        var individual: Individual! = publicRealm.object(ofType: Individual.self, forPrimaryKey: userID)
        if individual == nil {
            individual = Individual(id: userID, title: userName)
            try! publicRealm.write {
                publicRealm.add(individual)
            }
        }
        return individual
    }
}

extension SemWorldDataLayer {
    static func queryPlaces() -> Results<Place> {
        realm.objects(Place.self)
    }
    
    static func createMockData() {
//        guard realm.objects(Place.self).count == 0 else {
//            return
//        }
//        
//        let places = [Place(title: "Tims-上滨生活广场", latitude: 31.260_402, longitude: 121.503_985), Place(title: "Tims-大学路", latitude: 31.304_107, longitude: 121.508_546)]
//        try! realm.write {
//            realm.add(places)
//        }
    }
}
