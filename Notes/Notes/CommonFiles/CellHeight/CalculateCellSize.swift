//
//  CalculateCellSize.swift
//  Notes
//
//  Created by MAC BOOK on 16/09/22.
//

import Foundation
import UIKit

class CalclulateCellSize {
    static let shared = CalclulateCellSize()
    func calculateSize(_ message: String, font: UIFont, width: CGFloat) -> CGSize {
        return (message as NSString?)?.boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size ?? CGSize(width: width, height: 100)
    }
}
