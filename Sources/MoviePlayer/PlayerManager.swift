//
//  PlayerManager.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import UIKit
import RxSwift
import RxCocoa
import NVActivityIndicatorView

public class PlayerManager {
  public static var shared = PlayerManager()
  
  private let disposeBag = DisposeBag()
  private let listServerUseCase = ListServerUseCase()
  private let domainUseCase = DomainUseCase()
  private var domain: String!
  private var ip: String!
  private var aesKey: String!
  private var cbcKey: String!
  private var allowPlay = false
  private var allowShowAds = false
  private var adsCompletionHandler: (() -> Void)?
  private var taskLoadingView: TaskLoadingView?
  
  private(set) var loadingType: NVActivityIndicatorType = .ballTrianglePath
  private(set) var blurBackgroundLoadingColor = UIColor(rgb: 0x000000)
  private(set) var alertLoadingColor = UIColor(rgb: 0x000000)
  private(set) var titleLoadingColor = UIColor(rgb: 0xFFFFFF)
  private(set) var indicatorLoadingColor = UIColor(rgb: 0xFFFFFF)
  
  private(set) var playType: NVActivityIndicatorType = .ballSpinFadeLoader
  private(set) var indicatorPlayColor = UIColor(rgb: 0xFFFFFF)
  private(set) var blurBackgroundPlayColor = UIColor(rgb: 0x000000)
  private(set) var backPlayColor = UIColor(rgb: 0x000000)
  private(set) var selectBlurBackgroundServerPlayColor = UIColor(rgb: 0xFFFFFF)
  private(set) var deselectBlurBackgroundServerPlayColor = UIColor(rgb: 0xFFFFFF)
  private(set) var borderServerPlayColor = UIColor(rgb: 0xFFFFFF)
  private(set) var selectTitleServerPlayColor = UIColor(rgb: 0xFFFFFF)
  private(set) var deselectTitleServerPlayColor = UIColor(rgb: 0xFFFFFF)
  
  public func config(ip: String, aes: String, cbc: String) {
    self.ip = ip
    self.aesKey = aes
    self.cbcKey = cbc
    domainUseCase.config { [weak self] appDomain in
      guard let self = self, let appDomain = appDomain else {
        return
      }
      self.setDomain(appDomain)
      self.loadTimePlay()
      self.loadTimeShowAds()
    }
  }
  
  public func changePlayColor(type: NVActivityIndicatorType? = nil,
                              indicator: UIColor? = nil,
                              blurBackground: UIColor? = nil,
                              back: UIColor? = nil,
                              selectBlurBackgroundServer: UIColor? = nil,
                              deselectBlurBackgroundServer: UIColor? = nil,
                              borderServer: UIColor? = nil,
                              selectTitleServer: UIColor? = nil,
                              deselectTitleServer: UIColor? = nil
  ) {
    if let type = type {
      self.playType = type
    }
    if let indicator = indicator {
      self.indicatorPlayColor = indicator
    }
    if let blurBackground = blurBackground {
      self.blurBackgroundPlayColor = blurBackground
    }
    if let back = back {
      self.backPlayColor = back
    }
    if let selectBlurBackgroundServer = selectBlurBackgroundServer {
      self.selectBlurBackgroundServerPlayColor = selectBlurBackgroundServer
    }
    if let deselectBlurBackgroundServer = deselectBlurBackgroundServer {
      self.deselectBlurBackgroundServerPlayColor = deselectBlurBackgroundServer
    }
    if let borderServer = borderServer {
      self.borderServerPlayColor = borderServer
    }
    if let selectTitleServer = selectTitleServer {
      self.selectTitleServerPlayColor = selectTitleServer
    }
  }
  
  public func changeLoading(type: NVActivityIndicatorType? = nil,
                            blurBackground: UIColor? = nil,
                            alert: UIColor? = nil,
                            title: UIColor? = nil,
                            indicator: UIColor? = nil
  ) {
    if let type = type {
      self.loadingType = type
    }
    if let blurBackground = blurBackground {
      self.blurBackgroundLoadingColor = blurBackground
    }
    if let alert = alert {
      self.alertLoadingColor = alert
    }
    if let title = title {
      self.titleLoadingColor = title
    }
    if let indicator = indicator {
      self.indicatorLoadingColor = indicator
    }
  }
  
  public func showMovie(name: String,
                        tmdbId: Int,
                        imdbId: String,
                        limitHandler: (() -> Void)?
  ) {
    guard allowLoad() else {
      limitHandler?()
      return
    }
    startTaskLoading()
    listServerUseCase.loadMovieServer(name: name,
                                      tmdbId: tmdbId,
                                      imdbId: imdbId) { [weak self] output in
      guard let self = self else {
        limitHandler?()
        return
      }
      self.stopTaskLoading()
      guard !output.isEmpty else {
        limitHandler?()
        return
      }
      self.play(servers: output)
    }
  }
  
  public func showTV(name: String,
                     season: Int,
                     episode: Int,
                     tmdbId: Int,
                     limitHandler: (() -> Void)?
  ) {
    guard allowLoad() else {
      limitHandler?()
      return
    }
    startTaskLoading()
    listServerUseCase.loadTVServer(name: name,
                                   season: season,
                                   episode: episode,
                                   tmdbId: tmdbId) { [weak self] output in
      guard let self = self else {
        limitHandler?()
        return
      }
      self.stopTaskLoading()
      guard !output.isEmpty else {
        limitHandler?()
        return
      }
      self.play(servers: output)
    }
  }
  
  public func getAllowShowAds() -> Bool {
    return allowShowAds
  }
  
  public func configAdsCompletionHandler(_ action: (() -> Void)?) {
    self.adsCompletionHandler = action
  }
}

extension PlayerManager {
  func getIP() -> String {
    return ip
  }
  
  func getAES() -> String {
    return aesKey
  }
  
  func getCBC() -> String {
    return cbcKey
  }
  
  func getDomain() -> String {
    return domain
  }
  
  private func setDomain(_ value: String) {
    self.domain = value
  }
  
  private func allowLoad() -> Bool {
    guard
      allowPlay,
      domain != nil,
      aesKey != nil,
      cbcKey != nil
    else {
      return false
    }
    return true
  }
  
  private func loadTimePlay() {
    listServerUseCase.getTimePlay { [weak self] startDateString in
      guard
        let self = self,
        let startDateString = startDateString,
        let startDate = startDateString.convertToDate()
      else {
        return
      }
      guard startDate.timeIntervalSince1970 <= Date().timeIntervalSince1970 else {
        return
      }
      self.allowPlay = true
    }
  }
  
  private func loadTimeShowAds() {
    listServerUseCase.getTimeShowAds { [weak self] startDateString in
      guard
        let self = self,
        let startDateString = startDateString,
        let startDate = startDateString.convertToDate()
      else {
        return
      }
      guard startDate.timeIntervalSince1970 <= Date().timeIntervalSince1970 else {
        return
      }
      self.allowShowAds = true
      self.adsCompletionHandler?()
    }
  }
  
  private func play(servers: [ServerViewModelProtocol]) {
    DispatchQueue.main.async {
      guard let topVC = UIApplication.topStackViewController() else {
        return
      }
      let playerView = PlayerView()
      playerView.frame = topVC.view.frame
      let listServerViewModel = ListServerViewModel()
      listServerViewModel.setListServer(servers)
      playerView.setViewModel(listServerViewModel)
      topVC.view.addSubview(playerView)
    }
  }
  
  private func startTaskLoading() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        return
      }
      self.taskLoadingView?.removeFromSuperview()
      guard let topVC = UIApplication.topStackViewController() else {
        return
      }
      let taskLoadingView = TaskLoadingView()
      taskLoadingView.frame = topVC.view.frame
      topVC.view.addSubview(taskLoadingView)
      self.taskLoadingView = taskLoadingView
    }
  }

  private func stopTaskLoading() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        return
      }
      self.taskLoadingView?.removeFromSuperview()
    }
  }
}
