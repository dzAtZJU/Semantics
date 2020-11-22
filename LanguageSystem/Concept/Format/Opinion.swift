import Foundation

// Reality <- Opinion; Poll; History
// 复杂被人为制造以浑水摸鱼
// 躲藏在大众之中
// 经不起人们的投入去分析
// Media: 大家关心的问题

protocol OpinionData: Codable {}

struct Opinion: Codable {
    enum Format: Int, Codable {
        case Personal
        case Poll
    }
    
    struct Individual: OpinionData {
        let isAgree: Bool
    }
    
    struct Poll: OpinionData {
        let agreePortion: Int
    }
    
    let title: String
    let format: Format
    let data: Data

    var opinionData: OpinionData {
        switch format {
        case .Personal:
            return try! JSONDecoder().decode(Individual.self, from: data)
        case .Poll:
            return try! JSONDecoder().decode(Poll.self, from: data)
        }
    }
}
