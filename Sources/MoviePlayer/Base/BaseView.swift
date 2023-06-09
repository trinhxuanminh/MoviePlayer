//
//  BaseView.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import UIKit

class BaseView: UIView, ViewProtocol {
  override init(frame: CGRect) {
    super.init(frame: frame)
    addComponents()
    setConstraints()
    setProperties()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func addComponents() {}
  
  func setConstraints() {}
  
  func setProperties() {}
  
  func setColor() {}
  
  func binding() {}
  
  override func draw(_ rect: CGRect) {
    setColor()
  }
}
