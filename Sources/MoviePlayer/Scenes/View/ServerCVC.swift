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
        blurEffectView.colorTintAlpha = 0.1
        blurEffectView.layer.borderWidth = 0.5
        blurEffectView.clipsToBounds = true
        return blurEffectView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
      label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    private var viewModel: ServerViewModelProtocol! {
        didSet {
            self.binding()
        }
    }

    override func setColor() {
      self.blurEffectView.layer.borderColor = UIColor(rgb: 0x7859FA).cgColor
    }

    override func addComponents() {
        self.contentView.addSubview(self.blurEffectView)
        self.blurEffectView.addSubview(self.nameLabel)
    }

    override func setConstraints() {
        self.blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
          make.trailing.leading.equalToSuperview().inset(16.0)
            make.height.equalTo(21)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.blurEffectView.layer.cornerRadius = self.blurEffectView.frame.height / 2
    }

    override func binding() {
        self.viewModel.name.bind { [weak self] name in
            guard let self = self else {
                return
            }
            guard let name = name else {
                self.nameLabel.text = "#" + "Unknown"
                return
            }
            self.nameLabel.text = "#" + name
        }.disposed(by: self.disposeBag)
    }
}

extension ServerCVC {
    func setViewModel(_ viewModel: ServerViewModelProtocol) {
        self.viewModel = viewModel
    }

    func select() {
        self.nameLabel.textColor = UIColor(rgb: 0x7859FA)
        self.blurEffectView.colorTint = UIColor(rgb: 0xFFFFFF)
    }

    func deselect() {
        self.nameLabel.textColor = UIColor(rgb: 0xFFFFFF)
        self.blurEffectView.colorTint = UIColor(rgb: 0x7859FA)
    }
}
