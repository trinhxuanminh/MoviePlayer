//
//  TaskLoadingView.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import UIKit
import CustomBlurEffectView
import NVActivityIndicatorView
import SnapKit

class TaskLoadingView: BaseView {
  private lazy var blurEffectView: CustomBlurEffectView = {
    let blurEffectView = CustomBlurEffectView()
    blurEffectView.blurRadius = AppSize.blurRadius
    blurEffectView.clipsToBounds = true
    return blurEffectView
  }()
  private lazy var alertView: UIView = {
    let view = UIView()
    view.clipsToBounds = true
    view.layer.cornerRadius = 10.0
    return view
  }()
  private lazy var loadingLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: AppSize.serverFont)
    label.text = "Loading"
    label.textAlignment = .center
    return label
  }()
  private lazy var loadingView: NVActivityIndicatorView = {
    let loadingView = NVActivityIndicatorView(frame: .zero)
    loadingView.type = PlayerManager.shared.loadingType
    loadingView.padding = AppSize.indicatorPadding
    loadingView.isHidden = true
    loadingView.startAnimating()
    return loadingView
  }()
  
  override func setColor() {
    blurEffectView.colorTint = PlayerManager.shared.blurBackgroundLoadingColor
    alertView.backgroundColor = PlayerManager.shared.alertLoadingColor
    loadingLabel.textColor = PlayerManager.shared.titleLoadingColor
    loadingView.color = PlayerManager.shared.indicatorLoadingColor
  }
  
  override func addComponents() {
    addSubview(blurEffectView)
    blurEffectView.addSubview(alertView)
    alertView.addSubview(loadingLabel)
    alertView.addSubview(loadingView)
  }
  
  override func setConstraints() {
    blurEffectView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    alertView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(170)
    }
    loadingView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-10)
      make.width.height.equalTo(AppSize.indicator)
    }
    loadingLabel.snp.makeConstraints { make in
      make.height.equalTo(AppSize.indicator)
      make.trailing.leading.equalToSuperview()
      make.top.equalTo(loadingView.snp.bottom).inset(-30)
    }
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    if loadingView.isAnimating {
      loadingView.stopAnimating()
      loadingView.startAnimating()
    }
  }
}
