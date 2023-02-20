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
  private var domain: String?
  private var allowShow: Bool?
  private var ip: String?
  private var taskLoadingView: TaskLoadingView?
  private(set) var backgroundColor = UIColor(rgb: 0x000000)
  private(set) var tintColor = UIColor(rgb: 0xFFFFFF)
  private(set) var loadingType: NVActivityIndicatorType = .ballTrianglePath
  
  public func configDomain(ip: String) {
    self.ip = ip
    domainUseCase.config { [weak self] appDomain in
      guard let self = self, let appDomain = appDomain else {
        return
      }
      self.setDomain(appDomain)
    }
  }
  
  public func changeColor(background: UIColor? = nil, tint: UIColor? = nil) {
    if let background = background {
      self.backgroundColor = background
    }
    if let tint = tint {
      self.tintColor = tint
    }
  }
  
  public func changeLoading(type: NVActivityIndicatorType) {
    self.loadingType = type
  }
  
  public func showMovie(name: String,
                        tmdbId: Int,
                        imdbId: String,
                        limitHandler: (() -> Void)?
  ) {
    guard allowShow != false else {
      return
    }
    guard domain != nil else {
      limitHandler?()
      print("Unknown domain!")
      return
    }
    startTaskLoading()
    listServerUseCase.loadMovieServer(name: name,
                                      tmdbId: tmdbId,
                                      imdbId: imdbId) { [weak self] output in
      guard let self = self, let output = output else {
        limitHandler?()
        return
      }
      self.stopTaskLoading()
      guard output.0 else {
        limitHandler?()
        self.allowShow = false
        return
      }
      self.play(servers: output.1)
    }
  }
  
  public func showTV(name: String,
                     season: Int,
                     episode: Int,
                     tmdbId: Int,
                     limitHandler: (() -> Void)?
  ) {
    guard allowShow != false else {
      return
    }
    guard domain != nil else {
      limitHandler?()
      print("Unknown domain!")
      return
    }
    startTaskLoading()
    listServerUseCase.loadTVServer(name: name,
                                   season: season,
                                   episode: episode,
                                   tmdbId: tmdbId) { [weak self] output in
      guard let self = self, let output = output else {
        limitHandler?()
        return
      }
      self.stopTaskLoading()
      guard output.0 else {
        limitHandler?()
        self.allowShow = false
        return
      }
      self.play(servers: output.1)
    }
  }
}

extension PlayerManager {
  func getIP() -> String {
    return ip!
  }
  
  func getDomain() -> String {
    return domain!
  }
  
  private func setDomain(_ value: String) {
    self.domain = value
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
