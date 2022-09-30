//
//  NotesProtocol.swift
//  Notes
//
//  Created by MAC BOOK on 15/09/22.
//

import Foundation
import UIKit

protocol NotesPresenterToRouterProtocol: AnyObject {
    static func presentNotesList() -> UIViewController
    static func presentNotesDetail(_ notes: Notes?) -> UIViewController
}
protocol NotesViewToPresenterProtocol: AnyObject {
    var view: NotesPresenterToViewProtocol? { get set }
    var interactor: NotesPresenterToInteractorProtocol? { get set }
    var router: NotesPresenterToRouterProtocol? { get set }
    
    func saveNotes(_ id: String, title: String, desc: String, image: Data?)
    func loadNotes()
}
protocol NotesPresenterToInteractorProtocol: AnyObject {
    var presenter: NotesInteractorToPresentorProtocol? {get set}
    var notesModel: [Notes]? { get set }
    func getNotesFromInteractor()
}
protocol NotesInteractorToPresentorProtocol: AnyObject {
    func showSuccess()
    func showError(_ error: Error)
}
protocol NotesPresenterToViewProtocol: AnyObject {
    func showSuccess()
    func ShowFailed(_ message: String)
}
