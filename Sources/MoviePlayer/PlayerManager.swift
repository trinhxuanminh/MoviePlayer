//
//  PlayerManager.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import UIKit
import RxSwift
import RxCocoa

public class PlayerManager {
  public static var shared = PlayerManager()
  
  private let disposeBag = DisposeBag()
  private let listServerUseCase = ListServerUseCase()
  private var domain: String?
  private var taskLoadingView: TaskLoadingView?
  
  public func setDomain(_ value: String) {
    self.domain = value
  }
  
  func getDomain() -> String {
    return domain!
  }
  
  public func showMovie(name: String,
                                 tmdbId: Int,
                                 limitHandler: (() -> Void)?
  ) {
    guard domain != nil else {
      return
    }
    startTaskLoading()
    listServerUseCase.loadMovieServer(name: name, tmdbId: tmdbId).bind(onNext: { [weak self] (allowShow, listServerViewModel) in
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
                     tmdbId: Int,
                     season: Int,
                     episode: Int,
                     limitHandler: (() -> Void)?
  ) {
    startTaskLoading()
    guard domain != nil else {
      return
    }
    listServerUseCase.loadTVServer(name: name, tmdbId: tmdbId, season: season, episode: episode).bind(onNext: { [weak self] (allowShow, listServerViewModel) in
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
