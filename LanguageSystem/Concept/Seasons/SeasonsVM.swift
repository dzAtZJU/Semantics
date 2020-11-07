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

enum Season: String, Phase, Codable, CaseIterable {    
    case Spring = "Spring"
    case Summer = "Summer"
    case Autumn = "Autumn"
    case Winter = "Winter"
    
    var next: Season {
        let allCases = Self.allCases
        var nextIndex = allCases.firstIndex(of: self)! + 1
        if nextIndex == allCases.endIndex {
            nextIndex = 0
        }
        return allCases[nextIndex]
    }
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
    let placeID: String
    
    var dayIndexPath = DayIndexPath(phase: Season.Spring, day: 0)
    
    var fileDataToken: NSKeyValueObservation?
    
    @Published var seasonInterpretation: SeasonsInterpretation! = nil
    
    let perspectiveInterpretation: PerspectiveInterpretation
    
    var season: Season {
        dayIndexPath.phase as! Season
    }
    
    var isTransitToNextPhase: Bool {
        dayIndexPath.day == 0
    }
    
    var title: String {
        season.rawValue
    }
    
    var progress: Float {
        guard numberOfDays(inSeason: season) != 0 else {
            return 1
        }
        return Float(dayIndexPath.day + 1) / Float(numberOfDays(inSeason: season))
    }
    
    init(placeID placeID_: String) {
        placeID = placeID_
        let privateLayer = SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!))
        perspectiveInterpretation = try! privateLayer.queryPlaceStory(placeID: placeID)!.perspectiveInterpretation_List.first { (item) throws-> Bool in
            item.perspectiveID == Concept.Seasons.title
        }!
        
        seasonInterpretation = try! JSONDecoder().decode(SeasonsInterpretation.self, from: perspectiveInterpretation.fileData!)
        fileDataToken = perspectiveInterpretation.observe(\.fileData, options: .new) { (_, change) in
            self.seasonInterpretation = try! JSONDecoder().decode(SeasonsInterpretation.self, from: change.newValue!!)
        }
        
    }
    
    func numberOfDays(inSeason season: Season) -> Int {
        seasonInterpretation.season2Days[season]!.count
    }
    
    func addADay(url: URL) {
        var newSeasonInterpretation = seasonInterpretation!
        newSeasonInterpretation.season2Days[season]!.append(url)
        SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!)).replacePerspectiveFileData(Concept.Seasons.title, fileData: try! JSONEncoder().encode(newSeasonInterpretation), toPlace: placeID)
    }
    
    func deleteADay() {
        var newSeasonInterpretation = seasonInterpretation!
        newSeasonInterpretation.season2Days[season]!.remove(at: dayIndexPath.day)
        updateDayIndexPathForDelete()
        SemWorldDataLayer(realm: RealmSpace.main.realm(RealmSpace.queryCurrentUserID()!)).replacePerspectiveFileData(Concept.Seasons.title, fileData: try! JSONEncoder().encode(newSeasonInterpretation), toPlace: placeID)
    }
    
    func updateDayIndexPathToNext() {
        guard numberOfDays(inSeason: season) != 0 else {
            dayIndexPath.phase = season.next
            return
        }
        
        if numberOfDays(inSeason: season) - 1 == dayIndexPath.day {
            updateDayIndexPathToNextSeason()
        } else {
            dayIndexPath.day += 1
        }
    }
    
    func updateDayIndexPathByOneDay() {
        dayIndexPath.day += 1
    }
    
    func updateDayIndexPathForDelete() {
        if dayIndexPath.day == numberOfDays(inSeason: season) - 1 {
            updateDayIndexPathToNextSeason()
        }
    }
    
    func updateDayIndexPathToNextSeason() {
        dayIndexPath.phase = season.next
        dayIndexPath.day = 0
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
        
        let celltype: PhasesVC.CellType = {
            let seasonDays = numberOfDays(inSeason: season)
            if seasonDays == 0 || seasonDays == dayIndexPath.day {
                return .Adding
            } else {
                return .Showing
            }
        }()
        let cell = phasesVC.dequeueReusableCell(withCellType: celltype, for: dayIndexPath)
        
        switch celltype {
        case .Adding:
            guard let cell = cell as? UISearchBar else {
                fatalError()
            }
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
