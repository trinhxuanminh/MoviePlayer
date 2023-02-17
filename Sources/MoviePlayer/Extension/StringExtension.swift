//
//  StringExtension.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import UIKit

public extension String {
  func heightText(width: CGFloat, font: UIFont) -> CGFloat {
    let maxSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
    let text: String = self
    return text.boundingRect(with: maxSize,
                             options: .usesLineFragmentOrigin,
                             attributes: [.font: font],
                             context: nil)
    .height + 1
  }
  
  func widthText(height: CGFloat, font: UIFont) -> CGFloat {
    let maxSize = CGSize(width: CGFloat(MAXFLOAT), height: height)
    let text: String = self
    return text.boundingRect(with: maxSize,
                             options: .usesLineFragmentOrigin,
                             attributes: [.font: font], context: nil)
    .width + 1
  }
}
