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
import SwifterSwift
import KRPullLoader

class SemSetsVC: UIViewController {
    
    var oceanLayer: OceanLayer!
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == %@ && oceanLayer == %@", NSNumber(booleanLiteral: isArchive), oceanLayer)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Word.displayOrder, ascending: true)]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    private var table: UITableView!
    
    private static let CellIdentifier = "SemSetsVC.Cell"
    
    private lazy var cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(rightBarCancelButttonTapped))
    
    private lazy var editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButttonTapped))
    
    private lazy var addButton: UIButton = {
        let tmp = UIButton(type: .contactAdd)
        tmp.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        tmp.frame.size = .init(width: 40, height: 40)
        tmp.contentVerticalAlignment = .fill
        tmp.contentHorizontalAlignment = .fill
        tmp.addTarget(self, action: #selector(addButttonTapped), for: .touchUpInside)
        return tmp
    }()
    
    private lazy var pullUpControl: KRPullLoadView = {
        let tmp = KRPullLoadView()
        tmp.delegate = self
        return tmp
    }()
    
    private lazy var actionBar: [UIBarButtonItem] = {
        var tmp = [
            UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped)),
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
    
    private lazy var bgLayer: CAGradientLayer = {
        let tmp = CAGradientLayer()
        tmp.colors = Theme.color(forProximity: Int(oceanLayer.proximity))
        tmp.startPoint = .init(x: 0, y: 0)
        tmp.endPoint = .init(x: 1, y: 0)
        return tmp
    }()
    
    let proximity: Int
    
    init(isArchive isArchive_: Bool, proximity proximity_: Int) {
        isArchive = isArchive_
        proximity = proximity_
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(oceanLayer oceanLayer_: OceanLayer, isArchive isArchive_: Bool = false) {
        isArchive = isArchive_
        oceanLayer = oceanLayer_
        proximity = 0
        super.init(nibName:  nil, bundle: nil)
    }
    
    // MARK: VC
    
    override func loadView() {
        view = UIView()
        
        view.layer.insertSublayer(bgLayer, at: 0)
        
        table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .clear
        table.allowsSelection = true
        table.allowsMultipleSelectionDuringEditing = true
        view.addSubview(table)
        
        view.addSubview(addButton)
        
        if !isArchive {
            tabBarItem = UITabBarItem(title: "Dictionary", image: UIImage(systemName: "tray.full"), selectedImage: nil)
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
        
        table.addPullLoadableView(pullUpControl, type: .loadMore)
        table.contentInset.top = 50
        table.contentInset.bottom = 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        table.frame = view.bounds
        table.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        tabBarController?.title = "Dictionary"
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        extendedLayoutIncludesOpaqueBars = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        bgLayer.frame = view.bounds
    }
    
    override func viewSafeAreaInsetsDidChange() {
        addButton.center = view.bounds.inset(by: view.safeAreaInsets).bottomRight - CGPoint(x: 40, y: 40)
    }
}

// Adaptive
extension SemSetsVC {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection!.hasDifferentColorAppearance(comparedTo: traitCollection) {
            bgLayer.colors = Theme.color(forProximity: CoreDataLayer1.shared.queryProximityOrder(proximity: proximity))
        }
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
            var nextOceanLayer = OceanLayerDataLayer.shared.queryByProximity(self.oceanLayer.proximity, operator: .larger, in: self.oceanLayer.sector!)
            if nextOceanLayer == nil {
                nextOceanLayer = OceanLayer(context: self.managedObjectContext)
                nextOceanLayer?.sector = self.oceanLayer.sector
                nextOceanLayer!.proximity = self.oceanLayer.proximity + 1
            }
            word.oceanLayer = nextOceanLayer
            word.displayOrder = Int16(nextOceanLayer!.words?.count ?? 0)
            completion(true)
        })])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration(actions: [UIContextualAction(style: .normal, title: "Pull", handler: { (_, _, completion) in
            let word = self.fetchedResultsController.object(at: indexPath)
            var previousOceanLayer = OceanLayerDataLayer.shared.queryByProximity(self.oceanLayer.proximity, operator: .less, in: self.oceanLayer.sector!)
            if previousOceanLayer == nil {
                for (i, l) in (self.oceanLayer.sector!.oceanLayers as! Set<OceanLayer>).sorted(by: \.proximity).enumerated() {
                    l.proximity = Int16(i + 1)
                }
                previousOceanLayer = OceanLayer(context: self.managedObjectContext)
                previousOceanLayer?.sector = self.oceanLayer.sector
                previousOceanLayer!.proximity = 0
            }
            word.oceanLayer = previousOceanLayer
            word.displayOrder = Int16(previousOceanLayer!.words?.count ?? 0)
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
extension SemSetsVC: KRPullLoadViewDelegate {
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        switch state {
        case let .loading(completionHandler):
            let page = parent!.parent!.parent as! UIPageViewController
            let next = page.dataSource!.pageViewController(page, viewControllerAfter: parent!.parent!)!
            page.setViewControllers([next], direction: .forward, animated: true, completion: nil)
            completionHandler()
        default:
            break
        }
    }
    
    @objc private func addButttonTapped() {
        let newWord = Word(context: managedObjectContext)
        newWord.oceanLayer = oceanLayer
        newWord.displayOrder = Int16(fetchedResultsController.fetchedObjects!.count)
        
        let vc = SemSetVC(word: newWord, title: nil, proximity: proximity)
        show(vc, sender: nil)
    }
    
    @objc private func editButttonTapped() {
        isInMultiSelection = true
        table.setEditing(true, animated: false)
        navigationItem.setRightBarButton(cancelButton, animated: true)
        
        setToolbarItems(actionBar, animated: true)
        navigationController!.setToolbarHidden(false, animated: true)
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
    
    @objc private func saveButtonTapped() {
        if let selectedWords = table.indexPathsForSelectedRows?.map({ (indexPath) -> Word in
            self.fetchedResultsController.object(at: indexPath)
        }) {
            var nextSector = SectorDataLayer.shared.queryByDisplayOrder(Int(oceanLayer.sector!.displayOrder), operator: .larger)
            if nextSector == nil {
                nextSector = Sector(context: managedObjectContext)
                nextSector!.displayOrder = SectorDataLayer.shared.queryByDisplayOrderEnding(.max) + 1
            }
            var oceanLayer = OceanLayerDataLayer.shared.queryByProximityEnding(.min, in: nextSector!)
            if oceanLayer == nil {
                oceanLayer = OceanLayer(context: managedObjectContext)
                oceanLayer?.sector = nextSector
            }
            let displayOrder = ((oceanLayer!.words as? Set<Word>)?.sorted(by: \.displayOrder).last?.displayOrder ?? -1) + 1
            for (i, w) in selectedWords.enumerated() {
                w.oceanLayer = oceanLayer
                w.displayOrder = displayOrder + Int16(i)
            }
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
