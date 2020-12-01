extension Array {
    subscript(indices: [Index]) -> [Element] {
        indices.map {
            self[$0]
        }
    }
}
