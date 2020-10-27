import Foundation

struct SemanticSection {
    let title: String
    let images: [ImageItem]
    
    var count: Int {
        images.count
    }
}

struct ImageItem: Hashable {
    let url: URL
    let title: String
    let subtitle: String
    
    let identifier = UUID()
    
    init(url url_: String, title title_: String, subtitle subtitle_: String) {
        url = URL(string: url_)!
        title = title_
        subtitle = subtitle_
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

class CountryHomeVM {
    var sections: [SemanticSection] = []
    
    static let test: CountryHomeVM = {
        var tmp = CountryHomeVM()
        tmp.sections.append(SemanticSection(title: "Indigenous", images: [ImageItem(url: "https://finland.fi/wp-content/uploads/2017/01/sami.png", title: "萨米人", subtitle: "芬兰原住民")]))
        
        tmp.sections.append(SemanticSection(title: "Seasons", images: [ImageItem(url: "https://finland.fi/wp-content/uploads/2017/06/swan.png", title: "天鹅", subtitle: "光明重回大地"), ImageItem(url: "https://finland.fi/wp-content/uploads/2016/05/emoji-out_of_office.png", title: "不在办公室", subtitle: "返璞归真"), ImageItem(url: "https://finland.fi/wp-content/uploads/2016/05/emoji-white_nights.png", title: "白夜", subtitle: "活蹦乱跳，不想睡觉！"), ImageItem(url: "https://finland.fi/wp-content/uploads/2016/05/emoji-kokko.png", title: "KOKKO", subtitle: "燃烧的感觉"), ImageItem(url: "https://finland.fi/wp-content/uploads/2017/06/lavatanssit.png", title: "LAVATANSSIT", subtitle: "萍水相逢的感觉"), ImageItem(url: "https://finland.fi/wp-content/uploads/2015/11/emoji-stuck.png", title: "冻住", subtitle: "终于意识到冬天来临的那种感觉"), ImageItem(url: "https://finland.fi/wp-content/uploads/2015/11/emoji-kaamos.png", title: "KAAMOS", subtitle: "终日不见太阳的那种感觉"), ImageItem(url: "https://finland.fi/wp-content/uploads/2015/11/emoji-bear.png", title: "熊", subtitle: "只想沉睡一整个冬天的那种感觉"), ImageItem(url: "https://finland.fi/wp-content/uploads/2015/11/emoji-christmaspart.png", title: "圣诞派对", subtitle: "参加派对的特殊感觉")]))
                            
        tmp.sections.append(SemanticSection(title: "Nurturing", images: [ImageItem(url: "https://finland.fi/wp-content/uploads/2016/05/emoji-baby_in_a_box.png", title: "盒子里的小宝宝", subtitle: "被人照料的那种感觉"), ImageItem(url: "https://finland.fi/wp-content/uploads/2016/05/emoji-moominmamma.png", title: "姆明妈妈", subtitle: "无私的爱"), ImageItem(url: "https://finland.fi/wp-content/uploads/2017/06/education.png", title: "教育", subtitle: "第一天走进学堂的感觉"), ImageItem(url: "https://finland.fi/wp-content/uploads/2017/06/association.png", title: "协会", subtitle: "志同道合的感觉"), ImageItem(url: "https://finland.fi/wp-content/uploads/2015/11/emoji-girlpower.png", title: "女性力量", subtitle: "女性一样能行的那种感觉"), ImageItem(url: "https://finland.fi/wp-content/uploads/2015/11/emoji-forest.png", title: "森林", subtitle: "渴望新鲜空气和寂静的那种感觉")]))
            
        tmp.sections.append(SemanticSection(title: "Life", images: [ImageItem(url: "https://finland.fi/wp-content/uploads/2016/05/emoji-pesapallo.png", title: "芬兰棒球", subtitle: "爱恨分明的心情"), ImageItem(url: "https://finland.fi/wp-content/uploads/2016/05/emoji-the_cap.png", title: "帽子", subtitle: "自由自在的心情")]))
        return tmp
    }()
}
