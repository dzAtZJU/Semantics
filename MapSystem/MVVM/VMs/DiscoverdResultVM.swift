import RealmSwift

struct PlaceConditionsVM {
    let conditions: [RealmSpace.SearchNextResult.PlaceConditions.ConditionInfo]
    init(conditions conditions_: [RealmSpace.SearchNextResult.PlaceConditions.ConditionInfo]) {
        conditions = conditions_
    }
    
    var count: Int {
        conditions.count
    }
    
    func conditionTitle(at: IndexPath) -> String {
        conditions[at.row].id
    }
    
    func title(at: IndexPath) -> String {
        let condition = conditions[at.row]
        return "\(conditionTitle(at: at)) backed up by \(condition.backers.count) visitors"
    }
    
    func dislike(at: IndexPath, completion: @escaping () -> Void) {
        let info = conditions[at.row]
        let conditionId = info.id
        let inds = info.backers.map(by: \.id)
        RealmSpace.userInitiated.async {
            RealmSpace.userInitiated.privatRealm.dislike(inds: inds, forCondition: conditionId)
            completion()
        }
    }
}

class DiscoverdResultVM {
    var thePlaceId: String?
    
    var placeConditionsVM: PlaceConditionsVM?
    
    let result: RealmSpace.SearchNextResult
    init(result result_: RealmSpace.SearchNextResult) {
        result = result_
    }
    
    func setPlaceId(_ value: String?) {
        thePlaceId = value
        if let value = value {
            let placeConditions = result.places.first { $0.placeId == value }
            placeConditionsVM = PlaceConditionsVM(conditions: placeConditions!.conditions)
        } else {
            placeConditionsVM = nil
        }
    }
    
    func title() -> String {
        "\(result.places.count) places found"
    }
}
