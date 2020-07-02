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

struct SemSetsVCView: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiViewController: SemSetsVC, context: Context) {
    }
    
    func makeUIViewController(context: Context) -> SemSetsVC {
        return SemSetsVC()
    }
}

class SemSetsVC: UIViewController {
    
    private var tabelView: UITableView!
    
    private static let CellIdentifier = "SemSetsVC.Cell"
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Word.name, ascending: true)]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    // MARK: VC
    
    override func loadView() {
        tabBarItem = UITabBarItem(title: "Dictionary", image: UIImage(systemName: "tray.full"), selectedImage: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(Self.rightBarButttonTapped))
        navigationItem.title = "Dictionary"
        
        view = UIView()
        tabelView = UITableView(frame: .zero, style: .insetGrouped)
        view.addSubview(tabelView)
    }
    
    override func viewDidLoad() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("\(error)")
        }
        
        tabelView.delegate = self
        tabelView.dataSource = self
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabelView.frame = view.bounds
        tabelView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        super.viewWillAppear(animated)
    }
}

extension SemSetsVC {
    private func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let word = fetchedResultsController.object(at: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.showsReorderControl = true
        cell.textLabel!.text = word.name
        cell.detailTextLabel?.text = ""
        if word.hasNeighborWords {
            cell.detailTextLabel!.attributedText = FontAwesomeIcon.f212Icon.attributedString(ofSize: 11, color: SyntaxHighlight.noteLinkInnerColor)
        }
    }
    
    @objc private func rightBarButttonTapped() {
        show(SemSetVC(word: nil, title: nil), sender: nil)
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
        let cell = tabelView.dequeueReusableCell(withIdentifier: Self.CellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: Self.CellIdentifier)
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
        let size = tabelView.cellForRow(at: indexPath)!.frame.size
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
}

extension SemSetsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = SemSetVC(word: fetchedResultsController.object(at: indexPath), title: nil)
        show(detailVC, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "Delete", handler: { (_, _, completion) in
            self.managedObjectContext.delete(self.fetchedResultsController.object(at: indexPath))
            completion(true)
        })])
    }
}

extension SemSetsVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tabelView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tabelView.insertSections(IndexSet([sectionIndex]), with: .fade)
        case .delete:
            tabelView.deleteSections(IndexSet([sectionIndex]), with: .fade)
        default:
            fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tabelView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            tabelView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tabelView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tabelView.deleteRows(at: [indexPath!], with: .fade)
            tabelView.insertRows(at: [newIndexPath!], with: .fade)
        default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tabelView.endUpdates()
    }
}
