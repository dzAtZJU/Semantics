////
////  ContentView.swift
////  Semantics
////
////  Created by Zhou Wei Ran on 2020/5/18.
////  Copyright © 2020 Paper Scratch. All rights reserved.
////
//
//import SwiftUI
//import CoreData
//
//struct ContentView: View {
//    @Environment(\.managedObjectContext) var managedObjectContext
//
//    @FetchRequest(
//        entity: Word.entity(),
//        sortDescriptors: [
//            NSSortDescriptor(keyPath: \Word.name, ascending: true)
//        ]
//    ) var words: FetchedResults<Word>
//
//    let numbers = [1, 2, 3]
//
//    @State var lastToken: NSPersistentHistoryToken? = nil {
//        didSet {
//
//            guard let token = lastToken,
//                let data = try? NSKeyedArchiver.archivedData(
//                    withRootObject: token,
//                    requiringSecureCoding: true
//                ) else { return }
//            do {
//                try data.write(to: tokenFile)
//            } catch {
//                let message = "Could not write token data"
//                print("###\(#function): \(message): \(error)")
//            }
//        }
//    }
//
//    @State var tokenFile: URL = {
//        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent(
//            "semantics",
//            isDirectory: true
//        )
//        if !FileManager.default.fileExists(atPath: url.path) {
//            do {
//                try FileManager.default.createDirectory(
//                    at: url,
//                    withIntermediateDirectories: true,
//                    attributes: nil
//                )
//            } catch {
//                let message = "Could not create persistent container URL"
//                print("###\(#function): \(message): \(error)")
//            }
//        }
//        return url.appendingPathComponent("token.data", isDirectory: false)
//    }()
//
//    var body: some View {
//        NavigationView {
//            List {
//                NavigationLink(
//                    destination: SemSetView(word: nil)
//                        .navigationBarTitle("", displayMode: .inline)) {
//                            Text("Add new word \(words.count)")
//                                .foregroundColor(.accentColor)
//                }
//
//                ForEach(words, id:\.self) { word in
//                    NavigationLink(
//                        destination: SemSetView(word: word)
//                    .navigationBarTitle("", displayMode: .inline)) {
//                                Text(word.name ?? "")
//                    }
//                }
//                .onDelete(perform: removeRows)
//            }
//            .navigationBarTitle("SemanticsSet")
//        }
//        .keyboardAdaptive()
//        .navigationViewStyle(StackNavigationViewStyle())
//        .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange, object: self.managedObjectContext.persistentStoreCoordinator).receive(on: RunLoop.main)) { _ in
//            let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(
//                after: self.lastToken
//            )
//
//            guard
//                let historyResult = try? self.managedObjectContext.execute(fetchHistoryRequest)
//                    as? NSPersistentHistoryResult,
//                let history = historyResult.result as? [NSPersistentHistoryTransaction]
//                else {
//                    fatalError("Could not convert history result to transactions.")
//            }
//            var filteredTransactions = [NSPersistentHistoryTransaction]()
//            for transaction in history {
//                let filteredChanges = transaction.changes!.filter { change -> Bool in
//                    return change.changedObjectID.entity.name == Word.entity().name
//                }
//                if !filteredChanges.isEmpty {
//                    filteredTransactions.append(transaction)
//                }
//                self.lastToken = transaction.token
//            }
//            if filteredTransactions.isEmpty { return }
//            for transaction in filteredTransactions {
//                self.managedObjectContext.perform {
//                    self.managedObjectContext.mergeChanges(
//                        fromContextDidSave: transaction.objectIDNotification()
//                    )
//                }
//            }
//        }
//    }
//
//
//    func removeRows(at offsets: IndexSet) {
//        for index in offsets {
//            managedObjectContext.delete(words[index])
//        }
//
//        do {
//            try managedObjectContext.save()
//        } catch {
//            fatalError("fail to delete \(error)")
//        }
//    }
//
//}
//
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        return ContentView().environment(\.managedObjectContext, context)
//    }
//}
