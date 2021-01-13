import Amplify
import Mapbox
import SemLog
import Combine
import RealmSwift
import SemRealm

struct TileInfo {
    let url: URL
    let quadCoordinates: [Double]
    let key: String
    let owner: String
}

class ATileMapM {
    let pub: AnyPublisher<TileInfo, Never>
    
    init(realm: Realm) {
        pub = realm.queryIndividual().partner_List.changesetPublisher
            .freeze()
            .flatMap { change -> AnyPublisher<Realm, Never> in
                let newPartners: [String] = {
                    switch change {
                    case .initial(let list):
                        return list.array
                    case .update(let list, _, let inserts, _):
                        return list[inserts]
                    case .error(let error):
                        fatalError("\(error)")
                    }
                }()
                
                return MultiRealmsAccess.loadRealms(partitionValues: newPartners, callbackQueue: RealmSpace.userInitiated.queue)
            }
            .prepend(realm)
            .receive(on: RealmSpace.userInitiated.queue)
            .flatMap { realm -> AnyPublisher<(RLMOwnerID, RealmCollectionChange<RealmSwift.List<RLMAWS3KeyCoordinateQuad>>), Never> in
                let owner = realm.partitionValue!
                return realm.queryIndividual().tile_List
                    .changesetPublisher
                    .freeze()
                    .map {
                        (owner, $0)
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { (owner: RLMOwnerID, changeset: RealmCollectionChange<RealmSwift.List<RLMAWS3KeyCoordinateQuad>>) -> AnyPublisher<(RLMOwnerID, RLMAWS3KeyCoordinateQuad), Never> in
                let newTiles: [RLMAWS3KeyCoordinateQuad] = {
                    switch changeset {
                    case .initial(let list):
                        return list.array
                    case .update(let list, _, let ins, _):
                        return list[ins]
                    case .error(let error):
                        fatalError("\(error)")
                    }
                }()
                return newTiles.publisher
                    .map {
                        (owner, $0)
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { (owner, rlmAWS3KeyCoordinateQuad) in
                Amplify.Storage.getURL(key: rlmAWS3KeyCoordinateQuad.aws3Key)
                    .resultPublisher
                    .assertNoFailure()
                    .map {
                        TileInfo(url: $0, quadCoordinates: rlmAWS3KeyCoordinateQuad.coordinateQuad.array, key: rlmAWS3KeyCoordinateQuad.aws3Key, owner: owner)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func saveTile(_ image: UIImage, coordinateQuad: [Double], identifier: String) {
        let key = "\(RealmSpace.userID!).\(UUID())"
        var token: AnyCancellable?
        token = Amplify.Storage.uploadData(key: key, data: image.pngData()!).resultPublisher
            .assertNoFailure()
            .receive(on: RealmSpace.userInitiated.queue)
            .sink { key in
                try! Realm.newPrivateRealm(queue: RealmSpace.userInitiated.queue).addTile(identifier: identifier, aws3Key: key, coordinateQuad: coordinateQuad)
                token = nil
            }
    }
}
