//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation
import RxSwift

protocol ListServerUseCaseProtocol {
  func loadMovieServer(name: String, tmdbId: Int, imdbId: String, completionHandler: @escaping ([ServerViewModelProtocol]) -> Void)
  func loadTVServer(name: String, season: Int, episode: Int, tmdbId: Int, completionHandler: @escaping ([ServerViewModelProtocol]) -> Void)
  func getTimePlay(completionHandler: @escaping (String?) -> Void)
  func getTimeShowAds(completionHandler: @escaping (Int?) -> Void)
}

class ListServerUseCase: ListServerUseCaseProtocol {
  private let itemRepository = ItemRepository()
  
  func loadMovieServer(name: String, tmdbId: Int, imdbId: String, completionHandler: @escaping ([ServerViewModelProtocol]) -> Void) {
    itemRepository.loadServer(input: .getMovieServer(name: name, tmdbId: tmdbId, imdbId: imdbId)) { output in
      completionHandler(output.map { server in
        let serverViewModel = ServerViewModel()
        serverViewModel.setServer(server)
        return serverViewModel
      })
    }
  }
  
  func loadTVServer(name: String, season: Int, episode: Int, tmdbId: Int, completionHandler: @escaping ([ServerViewModelProtocol]) -> Void) {
    itemRepository.loadServer(input: .getTVServer(name: name, season: season, episode: episode, tmdbId: tmdbId)) { output in
      completionHandler(output.map { server in
        let serverViewModel = ServerViewModel()
        serverViewModel.setServer(server)
        return serverViewModel
      })
    }
  }
  
  func getTimePlay(completionHandler: @escaping (String?) -> Void) {
    itemRepository.getTimePlay(completionHandler: completionHandler)
  }
  
  func getTimeShowAds(completionHandler: @escaping (Int?) -> Void) {
    itemRepository.getTimeShowAds(completionHandler: completionHandler)
  }
}
