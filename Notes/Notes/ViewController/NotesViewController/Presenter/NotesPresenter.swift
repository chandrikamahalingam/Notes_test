//
//  NotesPresenter.swift
//  Notes
//
//  Created by MAC BOOK on 15/09/22.
//

import Foundation
import UIKit
import CoreData

class NotesPresenter: NotesViewToPresenterProtocol {
    
    
    var view: NotesPresenterToViewProtocol?
    var interactor: NotesPresenterToInteractorProtocol?
    var router: NotesPresenterToRouterProtocol?
    
    func loadNotes() {
        interactor?.getNotesFromInteractor()
    }
    func saveNotes(_ id: String, title: String, desc: String, image: Data?) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            
            let context = delegate.persistentContainer.viewContext
            let fetchNotes: NSFetchRequest<Notes> = Notes.fetchRequest()
            fetchNotes.predicate = NSPredicate(format: "id = %@", id as String)

            let results = try? context.fetch(fetchNotes)
            
            if results?.count == 0 {
               // here you are inserting
                let entity = Notes(context: context)
                entity.id = id
                entity.archived = false
                entity.title = title
                entity.body = desc
                entity.created_time = Date()
                if image != nil {
                    entity.image = "image_url"
                    entity.image_data = image
                }
            }
            else {
                let entity = results?.first ?? Notes(context: context)
                entity.archived = false
                entity.title = title
                entity.body = desc
                entity.image = "image_url"
                entity.created_time = Date()
                if image != nil {
                    entity.image_data = image
                }
            }
            
            do {
                try context.save()
                view?.showSuccess()
                print("LocalDB updated Successfully")
            } catch  {
                view?.ShowFailed("Unable to Store on local Data")
                print("Unable to Store on local Data")
            }
        }
        
    }
    
}
extension NotesPresenter: NotesInteractorToPresentorProtocol {
    func showSuccess() {
        view?.showSuccess()
    }
    
    func showError(_ error: Error) {
        switch error {
        case NetworkError.badURL:
            view?.ShowFailed("Bad URL!!")
        case NetworkError.badHTTPResponse:
            view?.ShowFailed("Bad Response!!")
        default:
            view?.ShowFailed(error.localizedDescription)
        }
        
    }
    
    
}
