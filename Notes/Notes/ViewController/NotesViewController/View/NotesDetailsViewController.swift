//
//  NotesDetailsViewController.swift
//  Notes
//
//  Created by MAC BOOK on 17/09/22.
//

import UIKit
import SDWebImage
import PhotosUI
import CoreData

class NotesDetailsViewController: UIViewController {
    
    let imageView = UIImageView()
    var titleTextView: SelfSizingTextView!
    let dateLabel = UILabel()
    var descTextView: SelfSizingTextView!
    var backItem: UIBarButtonItem!
    var attachmentItem: UIBarButtonItem!
    var saveItem: UIBarButtonItem!
    var notes: Notes!
    var imageData: Data?
    
    
    
    weak var presenter: NotesViewToPresenterProtocol?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    var container: NSPersistentContainer!
    lazy var fetchedResultsController: NSFetchedResultsController<Notes> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Notes> = Notes.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "created_time", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "image != nil")
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    var collectionView: UICollectionView!
    var selectedIndex = 0
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
        super.init(nibName: nil, bundle: nil)
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        imageView.contentMode = .scaleAspectFit
        self.titleTextView = SelfSizingTextView()
        self.titleTextView.delegate = self
        self.titleTextView.backgroundColor = .clear
        self.titleTextView.config("Title", font: LARGE_TITLE_FONT, color: UIColor.lightText, allignment: .left)
        self.dateLabel.config("", font: UIFont.systemFont(ofSize: 13), color: UIColor.lightGray, allignment: .left)
        self.descTextView = SelfSizingTextView()
        self.descTextView.delegate = self
        self.descTextView.backgroundColor = .clear
        self.descTextView.config("Description", font: DESC_FONT, color: UIColor.lightText, allignment: .left)
        self.descTextView.contentInset = .zero
        self.titleTextView.isScrollEnabled = false
        self.titleTextView.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        self.descTextView.isScrollEnabled = false
        self.descTextView.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.black
        collectionView.isPagingEnabled = true
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = .horizontal


        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        self.configureSubviews()
        self.setupConstraints()
        self.configUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        registerForKeyboardNotifications()
        self.loadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.removeForKeyboardNotifications()
    }
    func configUI() {
        // Request permission to access photo library
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
            DispatchQueue.main.async { [unowned self] in
            }
        }
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            self.container = delegate.persistentContainer
            do {
                try self.fetchedResultsController.performFetch()
            } catch {
            }
        }
        configNavigationView()
    }
    @objc func backButtonAct() {
        if !self.collectionView.isHidden  {
            self.navigationController?.navigationBar.backgroundColor = .black
            self.navigationItem.rightBarButtonItems = [saveItem, attachmentItem]
            self.collectionView.isHidden = true
            return
        }
        self.navigationController?.viewControllers.removeLast()
    }
    func configNavigationView() {
        self.backItem = UIBarButtonItem(image: UIImage(named: "left-arrow"), style: .plain, target: self, action: #selector(self.backButtonAct))
        self.navigationItem.leftBarButtonItem = backItem
        self.attachmentItem = UIBarButtonItem(image: UIImage(named: "attachments"), style: .plain, target: self, action: #selector(attachmentItemAct))
        attachmentItem.tintColor = UIColor.white
        self.saveItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveItemAct))
        saveItem.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItems = [saveItem, attachmentItem]
    }
    private func configureSubviews() {
        view.addSubview(scrollView)
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        scrollView.addSubview(stackView)
        view.addSubview(collectionView)
        self.collectionView.isHidden = true
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        self.updateStackViewConstraint(0)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleTextView)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(descTextView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        descTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: self.stackView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: self.stackView.rightAnchor),
            imageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/2.5)
        ])
        NSLayoutConstraint.activate([
            titleTextView.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 10),
            descTextView.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 10),
            dateLabel.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 10)
        ])
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewImageAct(_:))))
        imageView.isUserInteractionEnabled = true
    }
    @objc func viewImageAct(_ tag: Int) {
        guard let notes = fetchedResultsController.fetchedObjects else { return  }
        self.selectedIndex = notes.firstIndex(of: self.notes) ?? 0
        self.navigationItem.rightBarButtonItems = nil
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.collectionView.isHidden = false

        self.collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            self.collectionView.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: .left, animated: false)
        }
    }
    func updateStackViewConstraint(_ bottom: CGFloat) {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -bottom),
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
        ])
    }
    func loadData() {
        if notes != nil {
            self.titleTextView.text = notes.title
            self.titleTextView.textColor = .white
            self.dateLabel.text = (notes.created_time ?? Date()).formatted()
            self.descTextView.attributedText = self.convertIntoAttributedString(markdownString: notes.body ?? "")
            self.descTextView.textColor = .white
            self.imageView.isHidden = true
            print("DESC TEXT: \(self.descTextView.attributedText!)")
            self.attachmentItem.tintColor = .white
            if let data = notes.image_data{
                self.imageView.isHidden = false
                self.imageView.image = UIImage(data: data)
                self.attachmentItem.tintColor = UIColor.green
            }
            else if let image = notes.image, let url = URL(string: image) {
                self.imageView.sd_setImage(with: url) { image, error, cache, url in
                    if error == nil {
                        self.attachmentItem.tintColor = UIColor.green
                        self.imageView.isHidden = false
                    }
                    
                }
            }
            
            self.titleTextView.tag = 1
            self.descTextView.tag = 1
        }
        else {
            self.imageView.isHidden = true
        }
    }
    func removeForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShown(_:)),name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)),name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShown(_ notificiation: NSNotification) {
        guard let keyboardFrame = notificiation.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        
        //        self.updateStackViewConstraint(keyboardHeight)
        //        self.scrollView.scrollToBottom(animated: true)
        // write source code handle when keyboard will show
    }
    @objc func keyboardWillBeHidden(_ notification: NSNotification) {
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        
        // write source code handle when keyboard will be hidden
    }
    @objc func saveItemAct() {
        var id = self.randomString(length: 4)
        if notes != nil {
            id = notes.id ?? id
        }
        self.presenter?.saveNotes(id, title: self.titleTextView.text!, desc: self.descTextView.text, image: imageData)
    }
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    @objc func attachmentItemAct() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    private func convertIntoAttributedString(markdownString: String) -> NSAttributedString {
        guard var attributedString = try? AttributedString(
            markdown: markdownString,
            options: AttributedString.MarkdownParsingOptions(allowsExtendedAttributes: true,
                                                             interpretedSyntax: .inlineOnlyPreservingWhitespace))
        else {
            return NSAttributedString(string: markdownString)
        }
        attributedString.font = DESC_FONT
        attributedString.foregroundColor = .white
        
        return NSAttributedString(attributedString)
    }
}
extension NotesDetailsViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated:true) {
            guard let result = results.first else { return }
            let prov = result.itemProvider
            prov.loadObject(ofClass: UIImage.self) { imageMaybe, errorMaybe in
                if let image = imageMaybe as? UIImage {
                    self.imageData = image.jpegData(compressionQuality: 0.5)
                    DispatchQueue.main.async {
                        self.imageView.image = image
                        self.imageView.isHidden = false
                        self.attachmentItem.tintColor = UIColor.green
                        // do something with the image
                    }
                }
            }
        }
    }
}
extension  NotesDetailsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.tag == 0 {
            textView.text = ""
            textView.textColor = .white
            textView.tag = 1
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 1 {
            if textView.text == "" {
                textView.textColor = .lightText
                textView.text = textView == titleTextView ? "Title" : "Description"
            }
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        
        
    }
}
extension NotesDetailsViewController: NotesPresenterToViewProtocol {
    func showSuccess() {
        let alert = UIAlertController(title: nil, message: "Saved Successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func ShowFailed(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
