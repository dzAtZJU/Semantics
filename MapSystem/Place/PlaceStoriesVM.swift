import Foundation
import RealmSwift

class PlaceStoriesVM {
    init() {
        
    }
    
    var count: Int {
        2
    }
    
    var firstPlaceStoryVM: APlaceStoryVM {
        MockPlaceStoryVM.mock1
    }
    
    func placeStoryVM(after vm: APlaceStoryVM) -> APlaceStoryVM? {
        if vm === MockPlaceStoryVM.mock1 {
            return MockPlaceStoryVM.mock2
        } else if vm === MockPlaceStoryVM.mock2 {
            return MockPlaceStoryVM.mock1
        } else {
            fatalError()
        }
    }
    
    func placeStoryVM(before vm: APlaceStoryVM) -> APlaceStoryVM? {
        if vm === MockPlaceStoryVM.mock1 {
            return MockPlaceStoryVM.mock2
        } else if vm === MockPlaceStoryVM.mock2 {
            return MockPlaceStoryVM.mock1
        } else {
            fatalError()
        }
    }
    
    func indexForPlaceStoryVM(_ vm: PlaceStoryVM) -> Int {
        if vm === MockPlaceStoryVM.mock1 {
            return 0
        } else if vm === MockPlaceStoryVM.mock2 {
            return 1
        } else {
            fatalError()
        }
    }
}
