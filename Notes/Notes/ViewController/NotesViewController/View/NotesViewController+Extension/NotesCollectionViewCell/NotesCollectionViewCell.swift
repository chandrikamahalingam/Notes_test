//
//  NotesCollectionViewCell.swift
//  Notes
//
//  Created by MAC BOOK on 15/09/22.
//

import UIKit

class NotesCollectionViewCell: UICollectionViewCell {
    
    let cardView = UIView()
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    var viewWidth = CGFloat(0)
    private lazy var stackView: UIStackView = {
      let stackView = UIStackView()
      stackView.axis = .vertical
        stackView.alignment = .leading
      stackView.spacing = 10
      stackView.translatesAutoresizingMaskIntoConstraints = false
      return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel.config("", font: UIFont.systemFont(ofSize: 16), color: UIColor.black, allignment: .left)
        self.titleLabel.numberOfLines = 0
        self.titleLabel.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        self.titleLabel.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        self.dateLabel.config("", font: UIFont.systemFont(ofSize: 13), color: UIColor.darkGray, allignment: .left)
        self.dateLabel.numberOfLines = 1
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        cardView.makeRounded(5)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
        
        cardView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10)
        ])
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        ])
    }
    func config(_ note: Notes) {
        self.cardView.backgroundColor = UIColor.random().lighter()
        self.titleLabel.text = note.title
        self.dateLabel.text = (note.created_time ?? Date()).formatted()
        if note.image == nil {
            self.stackView.alignment = .leading
        }
        else {
            self.stackView.alignment = .trailing
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
