//
//  PlayerManager.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import UIKit
import NVActivityIndicatorView

public typealias Handler = (() -> Void)

public class PlayerManager {
  public static var shared = PlayerManager()
  
  private var domain: String!
  private var ip: String!
  private var aesKey: String!
  private var cbcKey: String!
  private var allowPlay = false
  private var allowShowAds = false
  private var adsCompletionHandler: Handler?
  private var taskLoadingView: TaskLoadingView?
  
  private(set) var loadingType: NVActivityIndicatorType = .ballTrianglePath
  private(set) var indicatorLoadingColor = UIColor.yellow
  private(set) var blurBackgroundLoadingColor = UIColor.black
  private(set) var alertLoadingColor = UIColor.black
  private(set) var titleLoadingColor = UIColor.yellow
  
  private(set) var playType: NVActivityIndicatorType = .ballSpinFadeLoader
  private(set) var indicatorPlayColor = UIColor.yellow
  private(set) var blurBackgroundPlayColor = UIColor.black
  private(set) var backPlayColor = UIColor.yellow
  private(set) var selectBlurBackgroundServerPlayColor = UIColor.gray
  private(set) var deselectBlurBackgroundServerPlayColor = UIColor.black
  private(set) var borderServerPlayColor = UIColor.gray
  private(set) var selectTitleServerPlayColor = UIColor.yellow
  private(set) var deselectTitleServerPlayColor = UIColor.white
  
  public func config(ip: String, aes: String, cbc: String) {
    self.ip = ip
    self.aesKey = aes
    self.cbcKey = cbc
    
    APIManager.shared.getConfig(input: .domain) { [weak self] configResponse in
      guard let self = self else {
        return
      }
      guard let configResponse = configResponse else {
        return
      }
      self.setDomain(configResponse.data)
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
    if let deselectTitleServer = deselectTitleServer {
      self.deselectTitleServerPlayColor = deselectTitleServer
    }
  }
  
  public func changeLoading(type: NVActivityIndicatorType? = nil,
                            indicator: UIColor? = nil,
                            blurBackground: UIColor? = nil,
                            alert: UIColor? = nil,
                            title: UIColor? = nil
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
                        limitHandler: Handler?
  ) {
    guard allowLoad() else {
      limitHandler?()
      return
    }
    startTaskLoading()
    let body = ServerBody(name: name, tmdbId: tmdbId, imdbId: imdbId, season: nil, episode: nil)
    loadServer(input: .movie, body: body, limitHandler: limitHandler)
  }
  
  public func showTV(name: String,
                     season: Int,
                     episode: Int,
                     tmdbId: Int,
                     limitHandler: Handler?
  ) {
    guard allowLoad() else {
      limitHandler?()
      return
    }
    startTaskLoading()
    let body = ServerBody(name: name, tmdbId: tmdbId, imdbId: nil, season: season, episode: episode)
    loadServer(input: .movie, body: body, limitHandler: limitHandler)
  }
  
  public func getAllowShowAds() -> Bool {
    return allowShowAds
  }
  
  public func configAdsCompletionHandler(_ action: Handler?) {
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
  
  private func loadServer(input: APIManager.Input, body: ServerBody, limitHandler: Handler?) {
    APIManager.shared.getServer(input: input,
                                body: body) { [weak self] servers in
      guard let self = self else {
        limitHandler?()
        return
      }
      self.stopTaskLoading()
      guard !servers.isEmpty else {
        limitHandler?()
        return
      }
      self.play(servers: servers)
    }
  }
  
  private func loadTimePlay() {
    APIManager.shared.getConfig(input: .timePlay) { [weak self] configResponse in
      guard let self = self else {
        return
      }
      guard
        let configResponse = configResponse,
        let startDate = configResponse.data.convertToDate()
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
    APIManager.shared.getConfig(input: .timeAds) { [weak self] configResponse in
      guard let self = self else {
        return
      }
      guard
        let configResponse = configResponse,
        let startDate = configResponse.data.convertToDate()
      else {
        self.adsCompletionHandler?()
        return
      }
      guard startDate.timeIntervalSince1970 <= Date().timeIntervalSince1970 else {
        self.adsCompletionHandler?()
        return
      }
      self.allowShowAds = true
      self.adsCompletionHandler?()
    }
  }
  
  private func play(servers: [Server]) {
    DispatchQueue.main.async {
//      guard let topVC = UIApplication.topStackViewController() else {
//        return
//      }
//      let playerView = PlayerView()
//      playerView.frame = topVC.view.frame
//      playerView.config(servers: servers)
//      topVC.view.addSubview(playerView)
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
