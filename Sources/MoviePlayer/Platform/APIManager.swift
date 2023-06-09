//
//  APIManager.swift
//  
//
//  Created by Trịnh Xuân Minh on 09/06/2023.
//

import Foundation
import CryptoSwift
import SwiftSoup

class APIManager {
  static let shared = APIManager()
  
  enum Input {
    case movie
    case tvShow
    case domain
    case timeAds
    case timePlay
  }
  
  private struct Keys {
    static let server = "li.team-detail"
    static let name = "span.marcelo"
    static let link = "span.zizou"
  }
  
  func getConfig(input: Input, completed: @escaping (ConfigResponse?) -> Void) {
    guard let request = prepareRequest(input: input, queryItems: nil) else {
      completed(nil)
      return
    }
    
    let session = URLSession.shared
    let task = session.dataTask(with: request) { (data, response, error) in
      guard let data = data else {
        completed(nil)
        return
      }
      do {
        let configResponse = try JSONDecoder().decode(ConfigResponse.self, from: data)
        completed(configResponse)
      } catch {
        completed(nil)
      }
    }
    task.resume()
  }
  
  func getServer(input: Input, body: ServerBody, completed: @escaping ([Server]) -> Void) {
    switch input {
    case .movie, .tvShow:
      break
    default:
      completed([])
      return
    }
    var queryItems = [
      URLQueryItem(name: "name", value: body.name),
      URLQueryItem(name: "tmdbId", value: String(body.tmdbId)),
      URLQueryItem(name: "html", value: "true"),
      URLQueryItem(name: "imdbId", value: body.imdbId),
      URLQueryItem(name: "season", value: String(body.season ?? 0)),
      URLQueryItem(name: "episode", value: String(body.episode ?? 0))
    ]
    guard let request = prepareRequest(input: input, queryItems: queryItems) else {
      completed([])
      return
    }
    
    let session = URLSession.shared
    let task = session.dataTask(with: request) { [weak self] (data, response, error) in
      guard let self = self else {
        return
      }
      guard let data = data else {
        completed([])
        return
      }
      guard let codingValue = String(data: data, encoding: .utf8) else {
        completed([])
        return
      }
      completed(self.filterHTML(self.decryptionHTML(codingValue: codingValue)))
    }
    task.resume()
  }
}

extension APIManager {
  private func prepareRequest(input: Input, queryItems: [URLQueryItem]?) -> URLRequest? {
    var url: URL?
    switch input {
    case .domain:
      url = URL(string: "http://" + PlayerManager.shared.getIP())
    default:
      url = URL(string: "http://" + PlayerManager.shared.getDomain())
    }
    
    guard
      let url = url,
      var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
    else {
      return nil
    }
    
    switch input {
    case .domain:
      urlComponents.path = "/mrq/cf/domain"
    case .movie:
      urlComponents.path = "/mrq/eteam"
    case .tvShow:
      urlComponents.path = "/mrq/eclub"
    case .timeAds:
      urlComponents.path = "/mrq/cf/time-ads"
    case .timePlay:
      urlComponents.path = "/mrq/cf/time"
    }
    
    if let queryItems = queryItems {
      urlComponents.queryItems = queryItems
    }
    
    guard let urlRequest = urlComponents.url else {
      return nil
    }
    var request = URLRequest(url: urlRequest)
    request.httpMethod = "GET"
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    return request
  }
  
  private func decryptionHTML(codingValue: String) -> String? {
    do {
      let aes = try AES(key: Array(PlayerManager.shared.getAES().utf8),
                        blockMode: CBC(iv: Array(PlayerManager.shared.getCBC().utf8)),
                        padding: .pkcs5)
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
  
  private func filterHTML(_ value: String?) -> [Server] {
    guard let value = value else {
      return []
    }
    do {
      let doc: Document = try SwiftSoup.parse(value)
      var values: [Server] = []
      for server in try doc.select(Keys.server).array() {
        values.append(Server(name: try server.select(Keys.name).text(),
                             link: try server.select(Keys.link).text()))
      }
      if values.isEmpty {
        print("There are no servers!")
      }
      print("List server:", values)
      return values
    } catch {
      return []
    }
  }
}
