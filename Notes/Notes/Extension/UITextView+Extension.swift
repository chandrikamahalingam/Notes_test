//
//  UITextView+Extension.swift
//  Notes
//
//  Created by MAC BOOK on 17/09/22.
//

import Foundation
import UIKit


extension UITextView {
    func config(_ text: String, font: UIFont?, color: UIColor?, allignment: NSTextAlignment) {
        self.text = text
        self.font = font
        self.textColor = color
        self.textAlignment = .left
        self.addDone()
    }
    func addDone() {
        let bar = UIToolbar()
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonAct))
        bar.items = [done]
        bar.sizeToFit()
        self.inputAccessoryView = bar
    }
    @objc func doneButtonAct() {
        self.endEditing(true)
    }
}
