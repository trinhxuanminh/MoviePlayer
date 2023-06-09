//
//  ServerCVC.swift
//
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import UIKit
import CustomBlurEffectView
import SnapKit

class ServerCVC: BaseCollectionViewCell {
  private lazy var blurEffectView: CustomBlurEffectView = {
    let blurEffectView = CustomBlurEffectView()
    blurEffectView.blurRadius = 20.0
    blurEffectView.layer.borderWidth = 0.5
    blurEffectView.clipsToBounds = true
    return blurEffectView
  }()
  
  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: AppSize.serverFont)
    return label
  }()
  
  override func setColor() {
    blurEffectView.layer.borderColor = PlayerManager.shared.borderServerPlayColor.cgColor
  }
  
  override func addComponents() {
    contentView.addSubview(blurEffectView)
    blurEffectView.addSubview(nameLabel)
  }
  
  override func setConstraints() {
    blurEffectView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    nameLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.leading.equalToSuperview().inset(AppSize.inset)
      make.height.equalTo(21)
    }
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    blurEffectView.layer.cornerRadius = blurEffectView.frame.height / 2
  }
}

extension ServerCVC {
  func config(server: Server) {
    self.nameLabel.text = "#" + server.name
  }
  
  func select() {
    nameLabel.textColor = PlayerManager.shared.selectTitleServerPlayColor
    blurEffectView.colorTint = PlayerManager.shared.selectBlurBackgroundServerPlayColor
  }
  
  func deselect() {
    nameLabel.textColor = PlayerManager.shared.deselectTitleServerPlayColor
    blurEffectView.colorTint = PlayerManager.shared.deselectBlurBackgroundServerPlayColor
  }
}
