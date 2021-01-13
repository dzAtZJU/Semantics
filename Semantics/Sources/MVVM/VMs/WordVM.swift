//
//  WordVM.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/2.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import CloudKit

protocol WordVM {
    var name: String { get }
    var subWords: [String] { get }
}

struct CDWordVM: WordVM {
    var name: String {
        word.name!
    }
    
    var subWords: [String] {
        word.subWords!
    }
    
    private let word: Word
    init(word word_: Word) {
        word = word_
    }
}

class CKWordVM: WordVM {
    var name: String {
        word[Schema.Word.name] as! String
    }
    
    var subWords: [String] {
        if let data = word[Schema.Word.subWords] as? NSData {
            return NSSecureUnarchiveFromDataTransformer().transformedValue(data) as! [String]
        } else {
            return []
        }
    }
    
    private let word: CKRecord
    init(word word_: CKRecord) {
        word = word_
        
        NotificationCenter.default.addObserver(self, selector: #selector(floatAdding), name: .floatAdding, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CKWordVM {
    @objc private func floatAdding(notification: Notification) {
        guard let payload = notification.object as? Notification.FloatAdding else {
            return
        }
        
        payload.word.communityRecordIDs!.append(word.recordID)
    }
}

enum Creature: Int {
    case none = 0
    case Inspiration = 1
    case Organ = 2
}
