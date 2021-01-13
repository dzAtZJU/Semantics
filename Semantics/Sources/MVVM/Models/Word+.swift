//
//  Word+.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/20.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import Foundation
import CloudKit

public typealias CKRecordID = CKRecord.ID

extension Word {
    public override func awakeFromFetch() {
        super.awakeFromInsert()
        
        if communityRecordIDs == nil {
            communityRecordIDs = [CKRecord.ID]()
        }
    }
}
