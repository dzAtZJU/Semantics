//
//  CoreDataLayer.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/21.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import CoreData
import UIKit

enum Operator: String {
    case equal = "="
    case less = "<"
    case larger = ">"
}

enum Ending {
    case min
    case max
}

protocol CoreDataAccessor {
    
    
    var appDelegate: AppDelegate {
        get
    }
    
    var managedObjectContext: NSManagedObjectContext {
        get
    }
}

extension CoreDataAccessor {
    var appDelegate: AppDelegate {
        return (UIApplication.shared.delegate as! AppDelegate)
    }
    
    var managedObjectContext: NSManagedObjectContext {
        get {
            return appDelegate.persistentContainer.viewContext
        }
    }
}

struct CoreDataLayer1: CoreDataAccessor {
    
    static let defaultProximity = 5
    
    static let shared = CoreDataLayer1()
    
    private init() {}
    
    func queryWord(name: String) -> Word? {
        let query: NSFetchRequest<Word> = Word.fetchRequest()
        query.predicate = NSPredicate(format: "name == %@", name)
        do {
            let words = try managedObjectContext.fetch(query)
            precondition(words.count <= 1)
            return words.first
        } catch {
            fatalError("\(error)")
        }
    }
    
    func queryOrCreateWord(name: String) -> Word {
        if let word = queryWord(name: name) {
            return word
        }
        
        let word = Word(context: managedObjectContext)
        word.name = name
        return word
    }
    
    func queryLink(oneEndWordName: String, theOtherEndWordName: String) -> Link? {
        precondition(oneEndWordName != theOtherEndWordName)
        
        let query: NSFetchRequest<Link> = Link.fetchRequest()
        query.predicate = NSPredicate(format: "(ANY words.name == %@) AND (ANY words.name == %@)", oneEndWordName, theOtherEndWordName)
        do {
            let links = try managedObjectContext.fetch(query)
            precondition(links.count <= 1)
            precondition(links.first?.words?.count ?? 2 == 2)
            return links.first
        } catch {
            fatalError("\(error)")
        }
    }
    
    func queryLinks() -> [Link] {
        let query: NSFetchRequest<Link> = Link.fetchRequest()
        do {
            let links = try managedObjectContext.fetch(query)
            return links
        } catch {
            fatalError("\(error)")
        }
    }
    
    func queryOrCreateLink(oneEndWordName: String, theOtherEndWordName: String) -> Link {
        if let link = queryLink(oneEndWordName: oneEndWordName, theOtherEndWordName: theOtherEndWordName) {
            return link
        }
        
        let oneEndWord = queryOrCreateWord(name: oneEndWordName)
        let theOtherEndWord = queryOrCreateWord(name: theOtherEndWordName)
        let link = Link(context: managedObjectContext)
        link.addToWords(NSSet(objects: oneEndWord, theOtherEndWord))
        return link
    }
    
    func createLinks(oneEndWordName: String, theOtherEndWordsName: Set<String>) {
        for theOtherEndWordName in theOtherEndWordsName {
            _ = queryOrCreateLink(oneEndWordName: oneEndWordName, theOtherEndWordName: theOtherEndWordName)
        }
    }
    
    func deleteLink(oneEndWordName: String, theOtherEndWordName: String) {
        precondition(oneEndWordName != theOtherEndWordName)
        if let link = queryLink(oneEndWordName: oneEndWordName, theOtherEndWordName: theOtherEndWordName) {
            managedObjectContext.delete(link)
        }
    }
    
    
    func deleteLinks(oneEndWordName: String, theOtherEndWordsName: Set<String>) {
        for theOtherEndWordName in theOtherEndWordsName {
            deleteLink(oneEndWordName: oneEndWordName, theOtherEndWordName: theOtherEndWordName)
        }
    }
}
