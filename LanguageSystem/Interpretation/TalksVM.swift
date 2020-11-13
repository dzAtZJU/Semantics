class TalksVM {
    struct Section {
        let titleItem: TitleItem
        let items: [IntepretationBirdItem]
    }
    
    let placeID: String
    
    var sections: [Section]
    
    init(placeID placeID_: String) {
        placeID = placeID_
        
        let privateLayer = SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!))
        
        let privatePerspectiveIDs = privateLayer.queryPerspectiveIDs(forPlace: placeID)
        var allPerspectiveIDs = Concept.allPublicTitles
        let orderedAllPerspectiveIDs = privatePerspectiveIDs + allPerspectiveIDs.removeAll(privatePerspectiveIDs)
        
        sections = orderedAllPerspectiveIDs.map {
            Section(titleItem: TitleItem(isInputing: false, title: $0, type: .Title), items: [IntepretationBirdItem(avatarWithName: ImageWithTitle(url: "https://scontent-nrt1-1.xx.fbcdn.net/v/t1.0-9/12074883_921505901266878_299061860009851622_n.jpg?_nc_cat=107&ccb=2&_nc_sid=09cbfe&_nc_ohc=8zfO9jputQgAX_1Cdor&_nc_ht=scontent-nrt1-1.xx&oh=8ffca2bc9f2b00e6f3ae647dbdd948ed&oe=5FC95D7C", title: "Mila", subtitle: ""), contentSources: ["google.com", "twitter.com", "instagram.com"])])
        }
    }
}
