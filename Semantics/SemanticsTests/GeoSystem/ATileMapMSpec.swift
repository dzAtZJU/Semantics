import Quick
import Nimble
import Combine
@testable import SemanticsB1

class ATileMapMSpec: QuickSpec {
    override func spec() {
        beforeEach {
            
        }
        
        it("receive after save tile") {
            let expectedCoord = [1.0,1,2,2,3,3,4,4]
            
            var tileInfo: TileInfo?
            RealmSpace.app.trySignUp(cred: .anonymous) { uid in
                RealmSpace.userInitiated.queue.async {
                    let m = ATileMapM(realm: RealmSpace.userInitiated.realm(uid))
                    var token: AnyCancellable?
                    token = m.pub.sink { value in
                        token = nil
                        tileInfo = value
                    }
                    
                    m.saveTile(UIImage(systemName: "plus")!, coordinateQuad: expectedCoord)
                }
            }
            
            expect(tileInfo?.quadCoordinates).toEventually(equal(expectedCoord), timeout: .seconds(300))
        }
        
        it("receive tile from friend") {
            let expectedCoord = [5.0,5,4,4,3,3,2,2]
            var tileInfo: TileInfo?
            
            RealmSpace.app.trySignUp(cred: .userAPIKey("80wPZEJv6wTMBIHX3IJ0wx9YJsFpPds5xbYJdntdNVIHnZYlzUR14KG0gTD6ij4r")) { uid1 in
                print("[Test] uid1: \(uid1)")
                RealmSpace.userInitiated.async {
                    ATileMapM(realm: RealmSpace.userInitiated.realm(uid1)).saveTile(UIImage(systemName: "folder.fill")!, coordinateQuad: expectedCoord)
                    RealmSpace.app.trySignUp(cred: .userAPIKey("BZqT1VtbrGduV16WYc3qtQxVsLP1ZAmiz8vyJdSbCWeuHXcSYd5Pwp759hpowqbi")) { uid2 in
                        print("[Test] uid1: \(uid2)")
                        RealmSpace.userInitiated.async {
                            var token: AnyCancellable?
                            let realm = RealmSpace.userInitiated.realm(uid2)
                            token = ATileMapM(realm: realm).pub.sink {
                                tileInfo = $0
                                token = nil
                            }
                            
                            MultiRealmsAccess.makeFriends(with: uid1) {_ in
                                
                            }
                        }
                    }
                    
                }
            }
            
            expect(tileInfo?.quadCoordinates).toEventually(equal(expectedCoord), timeout: .seconds(300))
        }
    }
}
