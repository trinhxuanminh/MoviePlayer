//
//  ItemRepository.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation
import RxSwift
import RxCocoa
import CryptoSwift
import SwiftSoup

protocol ItemRepositoryProtocol {
  func loadServer(input: ItemServerInput, completionHandler: @escaping ([Server]) -> Void)
  func getTimePlay(completionHandler: @escaping (String?) -> Void)
  func getTimeShowAds(completionHandler: @escaping (String?) -> Void)
}

class ItemRepository: APIService, ItemRepositoryProtocol {
  private struct Keys {
    static let server = "li.team-detail"
    static let name = "span.marcelo"
    static let link = "span.zizou"
  }
  
  func loadServer(input: ItemServerInput, completionHandler: @escaping ([Server]) -> Void) {
    requestString(input) { [weak self] encrypted in
      guard let self = self else {
        completionHandler([])
        return
      }
      guard let encrypted = encrypted else {
        completionHandler([])
        return
      }
      completionHandler(self.filterHTML(self.decryptionHTML(codingValue: encrypted)))
    }
  }
  
  func getTimePlay(completionHandler: @escaping (String?) -> Void) {
    request(ItemServerInput.getTimePlay) { output in
      guard let output = output, let time = output["data"] as? String else {
        completionHandler(nil)
        return
      }
      completionHandler(time)
    }
  }
  
  func getTimeShowAds(completionHandler: @escaping (String?) -> Void) {
    request(ItemServerInput.getTimeShowAds) { output in
      guard let output = output, let time = output["data"] as? String else {
        completionHandler(nil)
        return
      }
      completionHandler(time)
    }
  }
}

extension ItemRepository {
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
