//
//  ServerCVC.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import UIKit
import CustomBlurEffectView
import SnapKit
import RxCocoa

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
  
  private var viewModel: ServerViewModelProtocol! {
    didSet {
      binding()
    }
  }
  
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
  
  override func binding() {
    viewModel.name.bind { [weak self] name in
      guard let self = self else {
        return
      }
      guard let name = name else {
        self.nameLabel.text = "#" + "Unknown"
        return
      }
      self.nameLabel.text = "#" + name
    }.disposed(by: disposeBag)
  }
}

extension ServerCVC {
  func setViewModel(_ viewModel: ServerViewModelProtocol) {
    self.viewModel = viewModel
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
