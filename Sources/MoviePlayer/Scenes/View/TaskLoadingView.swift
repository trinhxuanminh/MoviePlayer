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
        blurEffectView.blurRadius = 15.0
        blurEffectView.colorTintAlpha = 0.5
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
      label.font = UIFont.systemFont(ofSize: 14.0)
        label.text = "Loading"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var loadingView: NVActivityIndicatorView = {
        let loadingView = NVActivityIndicatorView(frame: .zero)
        loadingView.type = .ballTrianglePath
        loadingView.padding = 30
        loadingView.isHidden = true
        loadingView.startAnimating()
        return loadingView
    }()
    
    override func setColor() {
        self.blurEffectView.colorTint = UIColor(rgb: 0x120D29)
        self.alertView.backgroundColor = UIColor(rgb: 0x120D29)
        self.loadingLabel.textColor = UIColor(rgb: 0xFFFFFF)
        self.loadingView.color = UIColor(rgb: 0x7347F3)
    }
    
    override func addComponents() {
        self.addSubview(self.blurEffectView)
        self.blurEffectView.addSubview(self.alertView)
        self.alertView.addSubview(self.loadingLabel)
        self.alertView.addSubview(self.loadingView)
    }
    
    override func setConstraints() {
        self.blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.alertView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(170)
        }
        
        self.loadingView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(AppSize.indicator)
        }
        
        self.loadingLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.trailing.leading.equalToSuperview()
            make.top.equalTo(self.loadingView.snp.bottom).inset(-30)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.loadingView.isAnimating {
            self.loadingView.stopAnimating()
            self.loadingView.startAnimating()
        }
    }
}
