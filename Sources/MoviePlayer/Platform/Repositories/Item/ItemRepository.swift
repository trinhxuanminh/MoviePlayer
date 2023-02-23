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
  func loadServer(input: ItemServerInput, completionHandler: @escaping ((Bool,[(name: String, link: String)])?) -> Void)
}

class ItemRepository: APIService, ItemRepositoryProtocol {
  private struct Keys {
    static let server = "li.team-detail"
    static let name = "span.marcelo"
    static let link = "span.zizou"
    static let time = "div.time"
  }
  
  func loadServer(input: ItemServerInput, completionHandler: @escaping ((Bool,[(name: String, link: String)])?) -> Void) {
    requestString(input) { [weak self] output in
      guard let self = self else {
        completionHandler((true, []))
        return
      }
      guard let codingValue = output else {
        completionHandler((true, []))
        return
      }
      completionHandler(self.filterHTML(self.decryptionHTML(codingValue: codingValue)))
    }
  }
}

extension ItemRepository {
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
  
  private func filterHTML(_ value: String?) -> (Bool,[(name: String, link: String)])? {
    guard let value = value else {
      return (true, [])
    }
    do {
      let doc: Document = try SwiftSoup.parse(value)
      guard let time = Double(try doc.select(Keys.time).text()) else {
        return (true, [])
      }
      let allowShow = Date().timeIntervalSince1970 * 1000 >= time
      print("Time:", time)
      guard allowShow else {
        print("Not allowed to show!")
        return (false, [])
      }
      var values: [(name: String, link: String)] = []
      for server in try doc.select(Keys.server).array() {
        values.append((try server.select(Keys.name).text(), try server.select(Keys.link).text()))
      }
      if values.isEmpty {
        print("There are no servers!")
      }
      print("List server:", values)
      return (true, values)
    } catch {
      return (true, [])
    }
  }
}
