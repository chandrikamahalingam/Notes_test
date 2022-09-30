//
//  UIView+Extension.swift
//  VIBER
//
//  Created by MAC BOOK on 10/09/22.
//

import Foundation
import UIKit

extension UIView {
    func makeRounded(_ radious: CGFloat) {
        self.layer.cornerRadius = radious
        self.clipsToBounds = true
    }
}
