//
//  ItemServerType.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation

enum ItemServerInput {
  case getMovieServer(name: String, tmdbId: Int, imdbId: String)
  case getTVServer(name: String, season: Int, episode: Int, tmdbId: Int)
}

extension ItemServerInput: APIInputBase {
  var headers: Dictionary<String, String> {
    return [
      "Content-Type": "application/json; charset=utf-8",
      "Accept": "application/json"
    ]
  }
  
  var requestType: Method {
    return .get
  }
  
  var parameters: Dictionary<String, Any>? {
    var parameters: [String: Any] = [:]
    switch self {
    case .getMovieServer(let name, let tmdbId, let imdbId):
      parameters["name"] = name
      parameters["tmdbId"] = tmdbId
      parameters["imdbId"] = imdbId
    case .getTVServer(let name, let season, let episode, let tmdbId):
      parameters["name"] = name
      parameters["episode"] = episode
      parameters["season"] = season
      parameters["tmdbId"] = tmdbId
    }
    return parameters
  }
  
  var urlString: String {
    switch self {
    case .getMovieServer:
      return "https://" + PlayerManager.shared.getDomain() + "/mrq/eteam"
    case .getTVServer:
      return "https://" + PlayerManager.shared.getDomain() + "/mrq/eclub"
    }
  }
}
