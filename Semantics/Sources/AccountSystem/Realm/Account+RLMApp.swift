import RealmSwift

extension App {
    func trySignUp(cred: Credentials, completion: @escaping (RLMOwnerID) -> Void) {
        // Decoding: https://jwt.io/
        login(credentials: cred) { result in
            let userID = try! result.get().id
            RealmSpace.userInitiated.realm(userID) { privateRealm in
                _ = privateRealm.tryCreateIndividual(userName: KeychainItem.currentUserName ?? String.random(ofLength: 6))
                completion(userID)
            }
        }
    }
}
