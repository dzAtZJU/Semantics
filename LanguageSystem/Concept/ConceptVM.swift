class ConceptVM {
    struct Section {
        let titleItem: TitleItem
        let items: [TitleItem]
    }
    
    let concept: Concept
    
    var sections: [Section] {
        concept.map.map { (link, neighbors) -> Section in
            Section(titleItem: TitleItem(title: link.title), items: neighbors.map({ TitleItem(title: $0.title) }))
        }
    }
    
    init(concept: Concept) {
        self.concept = concept
    }
}


