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
import WebKit

class PlayerView: BaseView {
  private lazy var blurEffectView: CustomBlurEffectView = {
    let blurEffectView = CustomBlurEffectView()
    blurEffectView.blurRadius = AppSize.blurRadius
    blurEffectView.clipsToBounds = true
    return blurEffectView
  }()
  private lazy var backButton: UIButton = {
    let button = UIButton()
    if let image = UIImage(named: "back", in: Bundle.module, compatibleWith: nil) {
      button.setImage(image, for: .normal)
    }
    button.addTarget(self, action: #selector(onTapBack), for: .touchUpInside)
    return button
  }()
  private lazy var loadingView: NVActivityIndicatorView = {
    let loadingView = NVActivityIndicatorView(frame: .zero)
    loadingView.type = PlayerManager.shared.playType
    loadingView.padding = AppSize.indicatorPadding
    return loadingView
  }()
  private lazy var webView: WKWebView = {
    let webView = WKWebView()
    webView.navigationDelegate = self
    webView.scrollView.isScrollEnabled = false
    webView.isHidden = true
    return webView
  }()
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.bounces = false
    collectionView.backgroundColor = .clear
    collectionView.registerCell(ofType: ServerCVC.self)
    collectionView.delegate = self
    collectionView.dataSource = self
    return collectionView
  }()
  
  private var servers: [Server] = []
  private var stateIndex: Int = 0
  
  override func setColor() {
    backButton.tintColor = PlayerManager.shared.backPlayColor
    blurEffectView.colorTint = PlayerManager.shared.blurBackgroundPlayColor
    loadingView.color = PlayerManager.shared.indicatorPlayColor
  }
  
  override func addComponents() {
    addSubview(blurEffectView)
    blurEffectView.addSubview(backButton)
    blurEffectView.addSubview(loadingView)
    blurEffectView.addSubview(collectionView)
    blurEffectView.addSubview(webView)
  }
  
  override func setConstraints() {
    blurEffectView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    backButton.snp.makeConstraints { make in
      make.top.equalTo(safeAreaLayoutGuide).inset(10)
      make.width.height.equalTo(21)
      make.leading.equalToSuperview().inset(AppSize.inset)
    }
    loadingView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(AppSize.indicator)
    }
    webView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.leading.equalToSuperview()
      make.height.equalTo(webView.snp.width).multipliedBy(AppSize.mediaScale)
    }
    collectionView.snp.makeConstraints { make in
      make.trailing.leading.equalToSuperview()
      make.height.equalTo(36)
      make.top.equalTo(webView.snp.bottom).inset(-20)
    }
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    loadingView.startAnimating()
  }
  
  @objc private func onTapBack() {
    removeFromSuperview()
  }
}

extension PlayerView: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if let url = webView.url, !url.path.isEmpty {
      loadingView.stopAnimating()
      webView.isHidden = false
    }
  }
  
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    webView.isHidden = true
    loadingView.startAnimating()
  }
  
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    webView.reload()
  }
}

extension PlayerView {
  func config(servers: [Server]) {
    self.servers = servers
    collectionView.reloadData()
    
    if let server = servers.first {
      changeServer(server)
    }
  }
  
  private func changeServer(_ server: Server) {
    guard let url = URL(string: server.link) else {
      return
    }
    self.webView.stopLoading()
    self.webView.load(URLRequest(url: url))
  }
}

extension PlayerView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return servers.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(ofType: ServerCVC.self, indexPath: indexPath)
    cell.config(server: servers[indexPath.item])
    if stateIndex == indexPath.item {
      cell.select()
    } else {
      cell.deselect()
    }
    return cell
  }
}

extension PlayerView: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let serverName = "#" + servers[indexPath.item].name
    let widthText = serverName.widthText(height: 21, font: UIFont.systemFont(ofSize: AppSize.serverFont))
    return CGSize(width: widthText + AppSize.inset * 2, height: collectionView.frame.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: .zero, left: AppSize.inset, bottom: .zero, right: AppSize.inset)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return AppSize.serverSpace
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return AppSize.serverSpace
  }
}

extension PlayerView {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard indexPath.item != stateIndex else {
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
    
    changeServer(servers[indexPath.item])
  }
}
