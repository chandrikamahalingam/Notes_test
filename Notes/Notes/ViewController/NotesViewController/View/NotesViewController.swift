//
//  ViewController.swift
//  Notes
//
//  Created by MAC BOOK on 13/09/22.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {

    var collectionView: UICollectionView!
    let buttonSize = CGFloat(60)
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.black
        button.clipsToBounds = true
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.addTarget(self, action: #selector(self.newButtonAct(_:)), for: .touchUpInside)
        button.layer.cornerRadius = CGFloat(buttonSize/2)
        return button
    }()
    
    private lazy var loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.tintColor = .white
        return indicator
    }()
    var container: NSPersistentContainer!
    var presenter: NotesViewToPresenterProtocol?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Notes> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Notes> = Notes.fetchRequest()

        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_time", ascending: false)]

        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()
    
    override func loadView() {
        view = UIView(frame: .zero)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // Initializers
    init() {
        // Create new `UICollectionView` and set `UICollectionViewFlowLayout` as its layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(collectionView)
        self.configUI()

    }
    required init?(coder aDecoder: NSCoder) {
        // Create new `UICollectionView` and set `UICollectionViewFlowLayout` as its layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        super.init(coder: aDecoder)
        self.view.addSubview(collectionView)
        self.configUI()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    func configNavigationView() {
        self.title = "Notes"
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.toolbar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.orange]
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = .black
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
    func configUI()  {
        self.configNavigationView()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // Layout constraints for `collectionView`
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
        self.view.addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        self.view.addSubview(addButton)
        self.addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            addButton.heightAnchor.constraint(equalToConstant: self.buttonSize),
            addButton.widthAnchor.constraint(equalToConstant: self.buttonSize)
        ])
        self.addButton.layer.masksToBounds = false
        self.addButton.layer.shadowColor = UIColor(white: 0.8, alpha: 0.5).cgColor
        self.addButton.layer.shadowOpacity = 0.5
        self.addButton.layer.shadowRadius = 1
        self.addButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        collectionView.backgroundColor = UIColor.black
        collectionView.dataSource = self
        collectionView.delegate = self
        self.collectionView.register(NotesCollectionViewCell.self, forCellWithReuseIdentifier: "NotesCollectionViewCell")
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            self.container = delegate.persistentContainer
            do {
                try self.fetchedResultsController.performFetch()
            } catch {
                let fetchError = error as NSError
                print("\(fetchError), \(fetchError.localizedDescription)")
            }
            guard let notes = fetchedResultsController.fetchedObjects else {
                return
            }
            if notes.count == 0 {
                self.loader.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    self.presenter?.loadNotes()
                    let layout = LiquidCollectionViewLayout()
                    guard let notes = self.fetchedResultsController.fetchedObjects else { return }
                    layout.notesArray = notes
                    self.collectionView.collectionViewLayout = layout
                }
            }
            else {
                let layout = LiquidCollectionViewLayout()
                guard let notes = self.fetchedResultsController.fetchedObjects else { return }
                layout.notesArray = notes
                self.collectionView.collectionViewLayout = layout
                self.collectionView.reloadData()
            }
            
        }
        else {
        
        }
    }
    @objc func newButtonAct(_ sender: UIButton) {
        self.navigationController?.viewControllers.append(NotesRouter.presentNotesDetail(nil))
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if let layout = collectionView.collectionViewLayout as? LiquidCollectionViewLayout {
            layout.isUpdateView = true
        }
    }
}

extension NotesViewController: NotesPresenterToViewProtocol {
    func showSuccess() {
        DispatchQueue.main.async {
            self.loader.stopAnimating()
            self.collectionView.reloadData()

        }
    }
    
    func ShowFailed(_ message: String) {
        DispatchQueue.main.async {
            self.loader.stopAnimating()
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true)
        }
        
    }
    
    
}
