//
//  CommunityVM.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/4.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import CloudKit

class CommunityVM: CoreDataAccessor {
    
    private(set) var wordVMs: [CKWordVM]!
    
    private let word: Word
    init(word word_: Word) {
        precondition(word_.communityRecordIDs!.count > 0)
        word = word_
    }
    
    func loadRecords(completion: @escaping () -> Void) {
        let op = CKFetchRecordsOperation(recordIDs: word.communityRecordIDs!)
        op.fetchRecordsCompletionBlock = {  recordsByRecordID, error in
            guard let recordsByRecordID = recordsByRecordID, error == nil else {
                fatalError()
            }
            self.wordVMs = recordsByRecordID.values.map {
                CKWordVM(word: $0)
            }
            completion()
        }
        CloukitSpace.shared.container.sharedCloudDatabase.add(op)
    }
}

