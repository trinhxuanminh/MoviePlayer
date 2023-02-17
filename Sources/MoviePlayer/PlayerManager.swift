//
//  PlayerManager.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import UIKit
import RxSwift
import RxCocoa

public struct PlayerManager {
  public static var shared = PlayerManager()
  
  private let disposeBag = DisposeBag()
  private let listServerUseCase = ListServerUseCase()
  private var domain: String?
  
  public mutating func setDomain(_ value: String) {
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
    listServerUseCase.loadMovieServer(name: name, tmdbId: tmdbId).bind(onNext: { (allowShow, listServerViewModel) in
      guard allowShow else {
        limitHandler?()
        return
      }
      play(servers: listServerViewModel)
    }).disposed(by: self.disposeBag)
  }
  
  public func showTV(name: String,
                     tmdbId: Int,
                     season: Int,
                     episode: Int,
                     limitHandler: (() -> Void)?
  ) {
    guard domain != nil else {
      return
    }
    listServerUseCase.loadTVServer(name: name, tmdbId: tmdbId, season: season, episode: episode).bind(onNext: { (allowShow, listServerViewModel) in
      guard allowShow else {
        limitHandler?()
        return
      }
      play(servers: listServerViewModel)
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
}
