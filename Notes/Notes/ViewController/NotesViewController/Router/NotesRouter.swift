//
//  NotesRouter.swift
//  Notes
//
//  Created by MAC BOOK on 15/09/22.
//

import Foundation
import UIKit

class NotesRouter: NotesPresenterToRouterProtocol {
    static func presentNotesList() -> UIViewController{
        let view = NotesViewController()
        let presenter: NotesViewToPresenterProtocol & NotesInteractorToPresentorProtocol = NotesPresenter()
        let router: NotesPresenterToRouterProtocol = NotesRouter()
        let interactor: NotesPresenterToInteractorProtocol = NotesInteractor()
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        view.presenter = presenter
        return view
    }
    static func presentNotesDetail(_ notes: Notes?) -> UIViewController{
        let view = NotesDetailsViewController()
        let presenter: NotesViewToPresenterProtocol & NotesInteractorToPresentorProtocol = NotesPresenter()
        let router: NotesPresenterToRouterProtocol = NotesRouter()
        let interactor: NotesPresenterToInteractorProtocol = NotesInteractor()
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        view.presenter = presenter
        if notes != nil {
            view.notes = notes
        }
        return view
    }
}
