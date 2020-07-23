//
//  SemSetsVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/7/23.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI
import Iconic
import SwifterSwift

class SemSetsVC: UIViewController {
    
    var oceanLayer: OceanLayer
    
    var isArchive = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(oceanLayer oceanLayer_: OceanLayer) {
        oceanLayer = oceanLayer_
        super.init(nibName:  nil, bundle: nil)
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == %@ && oceanLayer == %@ && creature != %@", NSNumber(booleanLiteral: isArchive), oceanLayer, NSNumber(integerLiteral: Creature.Inspiration.rawValue))
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Word.displayOrder, ascending: true)]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    private lazy var table: UITableView = {
        let tmp = OneFingerTableView(frame: .zero, style: .insetGrouped)
        tmp.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tmp.backgroundColor = .clear
        tmp.allowsSelection = true
        tmp.allowsMultipleSelectionDuringEditing = true
        return tmp
    }()
    
    private static let CellIdentifier = "SemSetsVC.Cell"
    
    // MARK: VC
    
    override func loadView() {
        view = UIView()
        
        view.addSubview(table)
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
        tabBarController?.title = "Dictionary"
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        extendedLayoutIncludesOpaqueBars = true
        super.viewWillAppear(animated)
    }
  
    
    override func viewSafeAreaInsetsDidChange() {
        table.frame = view.bounds.inset(by: view.safeAreaInsets)
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
    
    private func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let word = fetchedResultsController.object(at: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.showsReorderControl = true
        cell.textLabel!.text = word.name
        cell.detailTextLabel?.text = ""
        if word.hasNeighborWords {
            cell.detailTextLabel!.attributedText = FontAwesomeIcon.f212Icon.attributedString(ofSize: 11, color: .secondaryLabel)
        }
    }
}

extension SemSetsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = SemSetVC(word: fetchedResultsController.object(at: indexPath), title: nil)
        show(detailVC, sender: nil)
    }
}

extension SemSetsVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        table.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
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
        table.endUpdates()
    }
}
