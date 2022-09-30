//
//  UIScrollView+Extension.swift
//  Notes
//
//  Created by MAC BOOK on 17/09/22.
//

import Foundation
import UIKit

extension UIScrollView {
   func scrollToBottom(animated: Bool) {
     if self.contentSize.height < self.bounds.size.height { return }
     let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
     self.setContentOffset(bottomOffset, animated: animated)
  }
}
