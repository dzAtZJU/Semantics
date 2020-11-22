import Foundation

// Reality: 外部环境
// Reality: 个体地位的意识，个体互相Support的意识，信任缺失的社会
// Reality: Unite Multiple Individuals，弱势者的声音
// Reality <- 微妙的，间接的，感受不到的东西
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
        let url: URL
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
