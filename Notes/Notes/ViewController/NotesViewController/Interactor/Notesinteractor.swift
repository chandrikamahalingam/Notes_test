//
//  Notesinteractor.swift
//  Notes
//
//  Created by MAC BOOK on 15/09/22.
//

import Foundation
import UIKit
import CoreData

class NotesInteractor: NotesPresenterToInteractorProtocol {
    
    var notesModel: [Notes]?
    var presenter: NotesInteractorToPresentorProtocol?
    
    func getNotesFromInteractor() {
        Task {
            do {
                let notes = try await API().loadItems(from: BASE_URL)
                DispatchQueue.main.async {
                    if let delegate = UIApplication.shared.delegate as? AppDelegate {
                        self.saveData(context: delegate.persistentContainer.viewContext, notes: notes)
                    }
                    else {
                        self.presenter?.showSuccess()
                    }
                }
                
            }
            catch {
                presenter?.showError(error)
            }
        }
    }
    func fetchFromLocalDB() {
        
    }
    // MARK: Saving JSONData to CoreData
    func saveData(context: NSManagedObjectContext, notes: [NotesModel]) {
        notes.forEach { note in
            let entity = Notes(context: context)
            entity.id = note.id
            entity.archived = note.archived ?? false
            entity.title = note.title
            entity.body = note.body
            if let time = note.created_time {
//                Date(timeIntervalSince1970: <#T##TimeInterval#>)
//                print("time")
                entity.created_time = Date(timeIntervalSince1970: Double(time))
            }
            entity.image = note.image
        }
        // Save Data to LocalDB
        do {
            try context.save()
            self.presenter?.showSuccess()
            print("LocalDB updated Successfully")
        } catch  {
            self.presenter?.showError(error)
            print("Unable to Store on local Data")
        }
        
    }
}
