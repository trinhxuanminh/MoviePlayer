//
//  ItemServerType.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation
import ObjectMapper
import Alamofire
import CryptoSwift
import SwiftSoup

enum ItemServerInput {
  case getMovieServer(name: String, tmdbId: Int, imdbId: String)
  case getTVServer(name: String, season: Int, episode: Int, tmdbId: Int)
}

extension ItemServerInput: APIInputBase {
  var headers: HTTPHeaders {
    return HTTPHeaders([
      "Content-Type": "application/json; charset=utf-8",
      "Accept": "application/json"
    ])
  }
  
  var urlString: String {
    switch self {
    case .getMovieServer:
      return "https://" + PlayerManager.shared.getDomain() + "/mrq/movie"
    case .getTVServer:
      return "https://" + PlayerManager.shared.getDomain() + "/mrq/series"
    }
  }
  
  var requestType: HTTPMethod {
    return .get
  }
  
  var encoding: ParameterEncoding {
    return requestType == .get ? URLEncoding.default : JSONEncoding.default
  }
  
  var parameters: [String : Any]? {
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
  
  var requireAccessToken: Bool {
    return true
  }
}

class ItemServerOutput: APIOutputBase {
  private struct Keys {
    static let server = "li.team-detail"
    static let name = "span.marcelo"
    static let link = "span.zizou"
    static let time = "div.time"
  }
  
  private(set) var allowShow: Bool = false
  private(set) var values: [(name: String, link: String)] = []
  
  init(html: String) {
    super.init()
    filterHTML(decryptionHTML(codingValue: html))
  }
  
  required init?(map: Map) {
    super.init(map: map)
  }
  
  override func mapping(map: Map) {
    super.mapping(map: map)
  }
  
  private func decryptionHTML(codingValue: String) -> String? {
    do {
      let aes = try AES(key: Array("f8jdsd5fhk9d1r5j".utf8), blockMode: CBC(iv: Array("8jdsd5fhk9d1r5fv".utf8)), padding: .pkcs5)
      guard let data = Data(base64Encoded: codingValue) else {
        return nil
      }
      
      let decryptedBytes = try aes.decrypt(data.bytes)
      let decryptedData = Data(decryptedBytes)
      return String(data: decryptedData, encoding: .utf8)
    } catch {
      return nil
    }
  }
  
  private func filterHTML(_ value: String?) {
    guard let value = value else {
      return
    }
    do {
      let doc: Document = try SwiftSoup.parse(value)
      guard let time = Double(try doc.select(Keys.time).text()) else {
        return
      }
      self.allowShow = Date().timeIntervalSince1970 * 1000 >= time
      guard allowShow else {
        print("Not allowed to show!")
        return
      }
      for server in try doc.select(Keys.server).array() {
        values.append((try server.select(Keys.name).text(), try server.select(Keys.link).text()))
      }
      allowShow = !values.isEmpty
      if values.isEmpty {
        print("There are no servers!")
      }
    } catch {
      return
    }
  }
}
