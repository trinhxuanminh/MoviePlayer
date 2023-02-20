//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation
import RxSwift

protocol ListServerUseCaseProtocol {
  func loadMovieServer(name: String, tmdbId: Int, imdbId: String, completionHandler: @escaping ((Bool, [ServerViewModelProtocol])?) -> Void)
  func loadTVServer(name: String, season: Int, episode: Int, tmdbId: Int, completionHandler: @escaping ((Bool, [ServerViewModelProtocol])?) -> Void)
}

class ListServerUseCase: ListServerUseCaseProtocol {
  private let itemRepository = ItemRepository()
  
  func loadMovieServer(name: String, tmdbId: Int, imdbId: String, completionHandler: @escaping ((Bool, [ServerViewModelProtocol])?) -> Void) {
    itemRepository.loadServer(input: .getMovieServer(name: name, tmdbId: tmdbId, imdbId: imdbId)) { output in
      guard let output = output else {
        completionHandler(nil)
        return
      }
      completionHandler((output.0, output.1.map { server in
        let serverViewModel = ServerViewModel()
        serverViewModel.setServer(server)
        return serverViewModel
      }))
    }
  }
  
  func loadTVServer(name: String, season: Int, episode: Int, tmdbId: Int, completionHandler: @escaping ((Bool, [ServerViewModelProtocol])?) -> Void) {
    return itemRepository.loadServer(input: .getTVServer(name: name, season: season, episode: episode, tmdbId: tmdbId)) { output in
      guard let output = output else {
        completionHandler(nil)
        return
      }
      completionHandler((output.0, output.1.map { server in
        let serverViewModel = ServerViewModel()
        serverViewModel.setServer(server)
        return serverViewModel
      }))
    }
  }
}
