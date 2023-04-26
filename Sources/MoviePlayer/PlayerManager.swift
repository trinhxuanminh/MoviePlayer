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
  
  private var taskLoadingView: TaskLoadingView?
  private(set) var backgroundColor = UIColor(rgb: 0x000000)
  private(set) var tintColor = UIColor(rgb: 0xFFFFFF)
  private(set) var loadingType: NVActivityIndicatorType = .ballTrianglePath
  
  public func configDomain(ip: String, aes: String, cbc: String) {
    self.ip = ip
    self.aesKey = aes
    self.cbcKey = cbc
    domainUseCase.config { [weak self] appDomain in
      guard let self = self, let appDomain = appDomain else {
        return
      }
      self.setDomain(appDomain)
    }
  }
  
//  public func changeColor(background: UIColor? = nil, tint: UIColor? = nil) {
//    if let background = background {
//      self.backgroundColor = background
//    }
//    if let tint = tint {
//      self.tintColor = tint
//    }
//  }
//
//  public func changeLoading(type: NVActivityIndicatorType) {
//    self.loadingType = type
//  }
  
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
    listServerUseCase.getTimeShowAds { [weak self] startDateValue in
      guard
        let self = self,
        let startDateValue = startDateValue
      else {
        return
      }
      guard Date(timeIntervalSince1970: Double(startDateValue)).timeIntervalSince1970 <= Date().timeIntervalSince1970 else {
        return
      }
      self.allowShowAds = true
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
