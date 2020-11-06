//    let urls = [
//        "https://finland.fi/zh/emoji/tiane/",
//
//        "https://finland.fi/zh/emoji/buzaibangongshi/",
//        "https://finland.fi/zh/emoji/baiye-2/",
//        "https://finland.fi/zh/emoji/kokko-4/",
//        "https://finland.fi/zh/emoji/lavatanssit-4/",
//
//        "https://finland.fi/zh/emoji/dongzhu/",
//        "https://finland.fi/zh/emoji/kaamos-10/",
//        "https://finland.fi/zh/emoji/xiong/",
//        "https://finland.fi/zh/emoji/shengdanpaidui/"
//    ]
import UIKit
import WebKit

enum Season: Int, Phase, Codable {
    case Spring
    case Summer
    case Autumn
    case Winter
}

struct SeasonsInterpretation: Interpretation {
    var season2Days: [Season: [URL]] = [
        Season.Spring: [],
        Season.Summer: [],
        Season.Autumn: [],
        Season.Winter: []
    ]
}

class SeasonsVM {

    var dayIndexPath = DayIndexPath(phase: Season.Spring, day: 0)
    
    var fileDataToken: NSKeyValueObservation?
    
    @Published var seasonInterpretation: SeasonsInterpretation! = nil
    
    init(placeID: String) {
        let privateLayer = SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!))
        let perspectiveInterpretation = try! privateLayer.queryPlaceStory(placeID: placeID)!.perspectiveInterpretation_List.first { (item) throws-> Bool in
            item.perspectiveID == Concept.Seasons.title
        }!
        
        seasonInterpretation = try! JSONDecoder().decode(SeasonsInterpretation.self, from: perspectiveInterpretation.fileData!)
        fileDataToken = perspectiveInterpretation.observe(\.fileData, options: .new) { (_, change) in
            self.seasonInterpretation = try! JSONDecoder().decode(SeasonsInterpretation.self, from: change.newValue!!)
        }
        
    }
    
    deinit {
        fileDataToken?.invalidate()
        fileDataToken = nil
    }
}

extension SeasonsVM: PhasesVCDatasource  {
    func phasesVC(_ phasesVC: PhasesVC, cellForDayAt dayIndexPath: DayIndexPath) -> UIView {
        guard let season = dayIndexPath.phase as? Season else {
            fatalError()
        }
        
        let celltype: PhasesVC.CellType = seasonInterpretation.season2Days[season]!.count == 0 ? .Adding : .Showing
        let cell = phasesVC.dequeueReusableCell(withCellType: celltype, for: dayIndexPath)
        
        switch celltype {
        case .Adding:
            guard let cell = cell as? UISearchBar else {
                fatalError()
            }
            cell.text = "asdasdasdssa"
            return cell
        case .Showing:
            guard let cell = cell as? WKWebView else {
                fatalError()
            }
            
            let url = seasonInterpretation.season2Days[season]![dayIndexPath.day]
            cell.navigationDelegate = phasesVC
            cell.load(URLRequest(url: url))
            return cell
        }
    }
}
