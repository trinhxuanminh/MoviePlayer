//
//  PlayerManager.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation
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
      print(allowShow, listServerViewModel)
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
  }
}
