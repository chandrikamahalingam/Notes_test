//
//  NotesViewController+Extension.swift
//  Notes
//
//  Created by MAC BOOK on 15/09/22.
//

import Foundation
import UIKit
import CoreData

extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let notes = fetchedResultsController.fetchedObjects else { return 0 }
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCollectionViewCell", for: indexPath) as! NotesCollectionViewCell
        // Fetch Quote
        let note = fetchedResultsController.object(at: indexPath)
        cell.config(note)
        if note.image == nil {
            cell.viewWidth = ((self.collectionView.frame.width)/2)-20
        }
        else {
            cell.viewWidth = (self.collectionView.frame.width)-30
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)
        self.navigationController?.viewControllers.append(NotesRouter.presentNotesDetail(note))
    }
}

extension NotesViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Changed!!!")
        if let layout = self.collectionView.collectionViewLayout as? LiquidCollectionViewLayout {
            guard let notes = self.fetchedResultsController.fetchedObjects else { return }
            layout.isUpdateView = true
            layout.notesArray = notes
        }
        self.collectionView.reloadData()
    }
}
