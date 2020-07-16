//
//  SemSetsVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/5.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI
import Iconic

class SemSetsVC: UIViewController {
    
    private var table: UITableView!
    
    private static let CellIdentifier = "SemSetsVC.Cell"
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == %@ && proximity == %@", NSNumber(booleanLiteral: isArchive), NSNumber(integerLiteral: proximity))
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Word.order, ascending: true)]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    private lazy var cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(rightBarCancelButttonTapped))
    
    private lazy var editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButttonTapped))
    
    private lazy var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarAddButttonTapped))
    
    private lazy var actionBar: [UIBarButtonItem] = {
        var tmp = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action:
                #selector(trashButtonTapped)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(orgnizeButtonTapped))
        ]
        if !isArchive {
            tmp.insert(UIBarButtonItem(title: "Archive", style: .done, target: self, action: #selector(archiveButtonTapped)), at: 0)
        }
        return tmp
    }()
    
    private lazy var searchResultsVC: SearchResultsVC = {
        let tmp = SearchResultsVC()
        tmp.delegate = self
        return tmp
    }()
    
    private lazy var searchController: UISearchController = {
        let tmp = UISearchController(searchResultsController: searchResultsVC)
        tmp.delegate = self
        tmp.searchResultsUpdater = self
        tmp.searchBar.autocapitalizationType = .none
        tmp.obscuresBackgroundDuringPresentation = false
        tmp.searchBar.delegate = self
        tmp.searchBar.scopeButtonTitles = []
        
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
        return tmp
    }()
    
    private var isInMultiSelection = false
    
    private var isUserDrivenChange = false
    
    private let isArchive: Bool
    
    let proximity: Int
    
    init(isArchive isArchive_: Bool, proximity proximity_: Int) {
        isArchive = isArchive_
        proximity = proximity_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: VC
    
    override func loadView() {
        view = UIView()
        
        table = UITableView(frame: .zero, style: .insetGrouped)
        table.allowsSelection = true
        table.allowsMultipleSelectionDuringEditing = true
        view.addSubview(table)
        
        if !isArchive {
            tabBarItem = UITabBarItem(title: "Dictionary", image: UIImage(systemName: "tray.full"), selectedImage: nil)
            navigationItem.leftBarButtonItem = addButton
            navigationItem.rightBarButtonItem = editButton
            navigationItem.title = "Dictionary"
        }
    }
    
    override func viewDidLoad() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("\(error)")
        }
        
        table.delegate = self
        table.dataSource = self
        fetchedResultsController.delegate = self
        navigationItem.searchController = searchController
        
        if let parent = parent?.parent as? UIPageViewController {
            let scrollView = parent.view.subviews.first {
                $0 is UIScrollView
                } as! UIScrollView
            table.gestureRecognizers?.forEach { recognizer in
                let name = String(describing: type(of: recognizer))
                guard name == "_UISwipeActionPanGestureRecognizer" else {
                    return
                }
                scrollView.panGestureRecognizer.require(toFail: recognizer)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        table.frame = view.bounds
        table.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        tabBarController?.title = "Dictionary"
        
        super.viewWillAppear(animated)
    }
}

// Adaptive
extension SemSetsVC {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
    }
}

extension SemSetsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: Self.CellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: Self.CellIdentifier)
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        fetchedResultsController.sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        fetchedResultsController.section(forSectionIndexTitle: title, at: index)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            managedObjectContext.delete(self.fetchedResultsController.object(at: indexPath))
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let word = self.fetchedResultsController.object(at: indexPath)
        guard let name = word.name else {
            return nil
        }
        let size = table.cellForRow(at: indexPath)!.frame.size
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { () -> UIViewController? in
            let textView = SemTextView(frame: .init(origin: .zero, size: size))
            textView.text = name.appending(neighborWords: Set(word.neighborWordsName))
            let vc = UIViewController()
            vc.view.addSubview(textView)
            vc.preferredContentSize = size
            return vc
        })
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if let indexPath = configuration.identifier as? NSIndexPath {
            let detailVC = SemSetVC(word: fetchedResultsController.object(at: indexPath as IndexPath), title: nil)
            show(detailVC, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        isUserDrivenChange = true
        defer {
            isUserDrivenChange = false
        }
        guard var fetchedObjects = fetchedResultsController.fetchedObjects else {
            return
        }
        let srcWord = fetchedResultsController.object(at: sourceIndexPath)
        fetchedObjects.remove(at: sourceIndexPath.row)
        fetchedObjects.insert(srcWord, at: destinationIndexPath.row)
        for (i, o) in fetchedObjects.enumerated() {
            o.order = Double(i)
        }
        appDelegate.saveContext()
    }
    
    private func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let word = fetchedResultsController.object(at: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.showsReorderControl = true
        cell.textLabel!.text = word.name
        cell.detailTextLabel?.text = ""
        print("cell \(word.name!) \(word.order)")
        if word.hasNeighborWords {
            cell.detailTextLabel!.attributedText = FontAwesomeIcon.f212Icon.attributedString(ofSize: 11, color: .secondaryLabel)
        }
    }
}

extension SemSetsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isInMultiSelection else {
            let detailVC = SemSetVC(word: fetchedResultsController.object(at: indexPath), title: nil)
            show(detailVC, sender: nil)
            return
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration(actions: [UIContextualAction(style: .normal, title: "Push", handler: { (_, _, completion) in
            let word = self.fetchedResultsController.object(at: indexPath)
            word.proximity += 1
            word.order = CoreDataLayer1.shared.queryMaxOrder() + 1
            completion(true)
        })])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration(actions: [UIContextualAction(style: .normal, title: "Pull", handler: { (_, _, completion) in
            let word = self.fetchedResultsController.object(at: indexPath)
            word.proximity -= 1
            word.order = CoreDataLayer1.shared.queryMaxOrder() + 1
            completion(true)
        })])
    }
    
    func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        guard !isInMultiSelection else {
            return
        }
        isInMultiSelection = true
        
        table.setEditing(true, animated: true)
        
        navigationItem.setRightBarButton(cancelButton, animated: true)
        setToolbarItems(actionBar, animated: true)
        navigationController!.setToolbarHidden(false, animated: true)
    }
}

extension SemSetsVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard !isUserDrivenChange else {
            return
        }
        table.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard !isUserDrivenChange else {
            return
        }
        switch type {
        case .insert:
            table.insertSections(IndexSet([sectionIndex]), with: .fade)
        case .delete:
            table.deleteSections(IndexSet([sectionIndex]), with: .fade)
        default:
            fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard !isUserDrivenChange else {
            return
        }
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                table.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            table.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            table.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            table.deleteRows(at: [indexPath!], with: .fade)
            table.insertRows(at: [newIndexPath!], with: .fade)
        default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard !isUserDrivenChange else {
            return
        }
        table.endUpdates()
    }
}

// MARK: Interaction
extension SemSetsVC {
    @objc private func rightBarAddButttonTapped() {
        let vc = SemSetVC(word: nil, title: nil, proximity: proximity)
        show(vc, sender: nil)
    }
    
    @objc private func editButttonTapped() {
        table.setEditing(true, animated: false)
        navigationItem.setRightBarButton(cancelButton, animated: true)
    }
    
    @objc private func rightBarCancelButttonTapped() {
        endMultipleSelection()
    }
    
    @objc private func archiveButtonTapped() {
        if let selectedWords = table.indexPathsForSelectedRows?.map({ (indexPath) -> Word in
            self.fetchedResultsController.object(at: indexPath)
        }) {
            managedObjectContext.perform {
                selectedWords.forEach {
                    $0.isArchived = true
                }
            }
            
        }
        
        endMultipleSelection()
    }
    
    @objc private func trashButtonTapped() {
        if let selectedWords = table.indexPathsForSelectedRows?.map({ (indexPath) -> Word in
            self.fetchedResultsController.object(at: indexPath)
        }) {
            managedObjectContext.perform {
                selectedWords.forEach {
                    self.managedObjectContext.delete($0)
                }
            }
            
        }
        
        endMultipleSelection()
    }
    
    @objc private func orgnizeButtonTapped() {
        if let selectedWords = table.indexPathsForSelectedRows?.map({ (indexPath) -> Word in
            self.fetchedResultsController.object(at: indexPath)
        }) {
            selectedWords.last!.subWords = Array(selectedWords.compactMap {
                $0.subWords
            }.joined())
            managedObjectContext.performAndWait {
                selectedWords.prefix(selectedWords.count - 1).forEach {
                    self.managedObjectContext.delete($0)
                }
            }
            show(SemSetVC(word: selectedWords.last!, title: nil), sender: self)
        }
        endMultipleSelection()
    }
    
    private func endMultipleSelection() {
        isInMultiSelection = false
        table.setEditing(false, animated: true)
        
        navigationItem.setRightBarButton(editButton, animated: true)
        setToolbarItems(nil, animated: true)
        navigationController!.setToolbarHidden(true, animated: true)
    }
}

// MARK: Search
extension SemSetsVC: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, SearchResultsVCDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let keys = searchController.searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces).components(separatedBy: " ") as [String]
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates:
            keys.map {
                findMatches(key: $0)
        })
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Word.name, ascending: true)]
        do {
            searchResultsVC.words = try managedObjectContext.fetch(request)
        } catch {
            fatalError()
        }
        
    }
    
    func searchResultsVC(_ searchResultsVC: SearchResultsVC, didSelectWord word: Word) {
        show(SemSetVC(word: word, title: nil), sender: self)
    }
    
    private func findMatches(key: String) -> NSPredicate {
        NSPredicate(format: "name CONTAINS %@", key)
    }
}
