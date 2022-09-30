//
//  UILabel+Extension.swift
//  VIBER
//
//  Created by MAC BOOK on 10/09/22.
//

import Foundation
import UIKit

extension UILabel {
    func config(_ text: String, font: UIFont?, color: UIColor?, allignment: NSTextAlignment) {
        self.text = text
        self.font = font
        self.textColor = color
        self.textAlignment = .left
    }
    
}
extension UILabel {
    class func textHeight(withWidth width: CGFloat, font: UIFont, text: String) -> CGFloat {
        return textSize(font: font, text: text, width: width).height
    }
    class func textSize(font: UIFont, text: String, width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.numberOfLines = 0
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size
    }
    func MarkdownText(text: String) {
        let attribute = try? NSMutableAttributedString.init(markdown: text)
        self.attributedText = attribute
    }
}
