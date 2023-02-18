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
  private var domain: String?
  private var taskLoadingView: TaskLoadingView?
  private(set) var backgroundColor = UIColor(rgb: 0x000000)
  private(set) var tintColor = UIColor(rgb: 0xFFFFFF)
  private(set) var loadingType: NVActivityIndicatorType = .ballTrianglePath
  
  public func setDomain(_ value: String) {
    self.domain = value
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
    guard domain != nil else {
      limitHandler?()
      print("Unknown domain!")
      return
    }
    startTaskLoading()
    listServerUseCase.loadMovieServer(name: name,
                                      tmdbId: tmdbId,
                                      imdbId: imdbId)
      .bind(onNext: { [weak self] (allowShow, listServerViewModel) in
      guard let self = self else {
        return
      }
      self.stopTaskLoading()
      guard allowShow else {
        limitHandler?()
        return
      }
      self.play(servers: listServerViewModel)
    }).disposed(by: self.disposeBag)
  }
  
  public func showTV(name: String,
                     season: Int,
                     episode: Int,
                     tmdbId: Int,
                     imdbId: String,
                     limitHandler: (() -> Void)?
  ) {
    startTaskLoading()
    guard domain != nil else {
      limitHandler?()
      print("Unknown domain!")
      return
    }
    listServerUseCase.loadTVServer(name: name,
                                   season: season,
                                   episode: episode,
                                   tmdbId: tmdbId,
                                   imdbId: imdbId)
      .bind(onNext: { [weak self] (allowShow, listServerViewModel) in
      guard let self = self else {
        return
      }
      self.stopTaskLoading()
      guard allowShow else {
        limitHandler?()
        return
      }
      self.play(servers: listServerViewModel)
    }).disposed(by: self.disposeBag)
  }
}

extension PlayerManager {
  func getDomain() -> String {
    return domain!
  }
  
  private func play(servers: [ServerViewModelProtocol]) {
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
  
  private func startTaskLoading() {
    taskLoadingView?.removeFromSuperview()
    guard let topVC = UIApplication.topStackViewController() else {
      return
    }
    let taskLoadingView = TaskLoadingView()
    taskLoadingView.frame = topVC.view.frame
    topVC.view.addSubview(taskLoadingView)
    self.taskLoadingView = taskLoadingView
  }
  
  private func stopTaskLoading() {
    taskLoadingView?.removeFromSuperview()
  }
}
