//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation
import RxSwift

protocol ListServerUseCaseProtocol {
  func loadMovieServer(name: String, tmdbId: Int) -> Observable<(Bool, [ServerViewModelProtocol])>
  func loadTVServer(name: String, tmdbId: Int, season: Int, episode: Int) -> Observable<(Bool, [ServerViewModelProtocol])>
}

class ListServerUseCase: ListServerUseCaseProtocol {
  private let itemRepository = ItemRepository()
  
  func loadMovieServer(name: String, tmdbId: Int) -> Observable<(Bool, [ServerViewModelProtocol])> {
    return itemRepository.loadServer(input: .getMovieServer(id: tmdbId, name: name))
      .map { itemServer in
        return (itemServer.allowShow, itemServer.values.map({ server in
          let serverViewModel = ServerViewModel()
          serverViewModel.setServer(server)
          return serverViewModel
        }))
      }
  }
  
  func loadTVServer(name: String, tmdbId: Int, season: Int, episode: Int) -> Observable<(Bool, [ServerViewModelProtocol])> {
    return itemRepository.loadServer(input: .getTVServer(id: tmdbId, name: name, season: season, episode: episode))
      .map { itemServer in
        return (itemServer.allowShow, itemServer.values.map({ server in
          let serverViewModel = ServerViewModel()
          serverViewModel.setServer(server)
          return serverViewModel
        }))
      }
  }
}
