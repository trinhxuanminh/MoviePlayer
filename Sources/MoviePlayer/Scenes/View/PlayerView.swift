//
//  PlayerView.swift
//
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import UIKit
import CustomBlurEffectView
import NVActivityIndicatorView
import SnapKit
import RxSwift
import WebKit
import RxDataSources

class PlayerView: BaseView {
  private lazy var blurEffectView: CustomBlurEffectView = {
    let blurEffectView = CustomBlurEffectView()
    blurEffectView.blurRadius = AppSize.blurRadius
    blurEffectView.clipsToBounds = true
    return blurEffectView
  }()
  private lazy var backButton: UIButton = {
    let button = UIButton()
    //        button.setImage(AppIcon.image(icon: .back), for: .normal)
    button.addTarget(self, action: #selector(onTapBack), for: .touchUpInside)
    return button
  }()
  private lazy var loadingView: NVActivityIndicatorView = {
    let loadingView = NVActivityIndicatorView(frame: .zero)
    loadingView.type = .ballSpinFadeLoader
    loadingView.padding = 30
    return loadingView
  }()
  private lazy var webView: WKWebView = {
    let webView = WKWebView()
    webView.navigationDelegate = self
    webView.scrollView.isScrollEnabled = false
    webView.isHidden = true
    return webView
  }()
  
  private var viewModel: ListServerViewModelProtocol! {
    didSet {
      binding()
    }
  }
  private var stateIndex: Int = 0
  
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.bounces = false
    collectionView.backgroundColor = .clear
    collectionView.register(ofType: ServerCVC.self)
    return collectionView
  }()
  
  override func setColor() {
    self.backButton.tintColor = UIColor(rgb: 0xFFFFFF)
    self.blurEffectView.colorTint = UIColor(rgb: 0x120D29)
    self.loadingView.color = UIColor(rgb: 0xFFFFFF)
  }
  
  override func addComponents() {
    self.addSubview(self.blurEffectView)
    self.blurEffectView.addSubview(self.backButton)
    self.blurEffectView.addSubview(self.loadingView)
    self.blurEffectView.addSubview(self.collectionView)
    self.blurEffectView.addSubview(self.webView)
  }
  
  override func setConstraints() {
    self.blurEffectView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    self.backButton.snp.makeConstraints { make in
      make.top.equalTo(self.safeAreaLayoutGuide).inset(10)
      make.width.height.equalTo(21)
      make.leading.equalToSuperview().inset(16)
    }
    
    self.loadingView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(20)
    }
    
    self.webView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.leading.equalToSuperview()
      make.height.equalTo(self.webView.snp.width).multipliedBy(10.0 / 16.0)
    }
    
    self.collectionView.snp.makeConstraints { make in
      make.trailing.leading.equalToSuperview()
      make.height.equalTo(36)
      make.top.equalTo(self.webView.snp.bottom).inset(-20)
    }
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    self.loadingView.startAnimating()
  }
  
  @objc private func onTapBack() {
    self.removeFromSuperview()
  }
  
  override func binding() {
    self.collectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<CustomSectionModel> { [weak self] dataSource, collectionView, indexPath, item in
      let cell = collectionView.dequeue(ofType: ServerCVC.self, indexPath: indexPath)
      if let serverViewModel = item as? ServerViewModelProtocol {
        cell.setViewModel(serverViewModel)
      }
      if let self = self, self.stateIndex == indexPath.item {
        cell.select()
      } else {
        cell.deselect()
      }
      return cell
    }
    
    self.viewModel.sections.bind(to: self.collectionView.rx.items(dataSource: dataSource))
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.itemSelected.bind { [weak self] indexPath in
      guard let self = self else {
        return
      }
      for cell in self.collectionView.visibleCells {
        if let cell = cell as? ServerCVC {
          cell.deselect()
        }
      }
      if let cell = self.collectionView.cellForItem(at: indexPath) as? ServerCVC {
        cell.select()
      }
      self.stateIndex = indexPath.item
      self.viewModel.selectAction.execute(indexPath)
    }.disposed(by: self.disposeBag)
    
    self.viewModel.stateLink.bind { [weak self] link in
      guard let self = self, let link = link, let url = URL(string: link) else {
        return
      }
      self.webView.stopLoading()
      self.webView.load(URLRequest(url: url))
    }.disposed(by: self.disposeBag)
  }
}

extension PlayerView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let serverName = "#" + self.viewModel.getServerName(index: indexPath.item)
    let widthText = serverName.widthText(height: 21, font: UIFont.systemFont(ofSize: 14))
    return CGSize(width: widthText + 16.0 * 2, height: collectionView.frame.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: .zero, left: 16.0, bottom: .zero, right: 16.0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 12.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 12.0
  }
}

extension PlayerView: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if let url = self.webView.url, !url.path.isEmpty {
      self.loadingView.stopAnimating()
      self.webView.isHidden = false
    }
  }
  
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    self.webView.isHidden = true
    self.loadingView.startAnimating()
  }
  
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    self.webView.reload()
  }
}

extension PlayerView {
  func setViewModel(_ viewModel: ListServerViewModelProtocol) {
    self.viewModel = viewModel
  }
}

