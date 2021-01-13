public extension RandomAccessCollection {
    subscript(_ indices: [Index]) -> [Element] {
        indices.map {
            self[$0]
        }
    }
}
