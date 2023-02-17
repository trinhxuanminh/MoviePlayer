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
  var movieDomain: String!
  var tvDomain: String!
  
  public mutating func showMovie(domain: String,
                                 name: String,
                                 tmdbId: Int,
                                 limitHandler: (() -> Void)?
  ) {
    self.movieDomain = domain
    listServerUseCase.loadMovieServer(name: name, tmdbId: tmdbId).bind(onNext: { (allowShow, listServerViewModel) in
      print(allowShow, listServerViewModel)
    }).disposed(by: self.disposeBag)
  }
  
  public func showTV(domain: String,
                     name: String,
                     tmdbId: Int,
                     season: Int,
                     episode: Int,
                     limitHandler: (() -> Void)?
  ) {}
}
