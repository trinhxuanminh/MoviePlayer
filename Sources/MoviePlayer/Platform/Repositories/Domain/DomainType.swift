//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 18/02/2023.
//

import Foundation
import ObjectMapper
import Alamofire
import CryptoSwift
import SwiftSoup

enum DomainInput {
  case config
}

extension DomainInput: APIInputBase {
  var headers: HTTPHeaders {
    return HTTPHeaders([
      "Content-Type": "application/json; charset=utf-8",
      "Accept": "application/json"
    ])
  }
  
  var urlString: String {
    switch self {
    case .config:
      return "http://" + PlayerManager.shared.getIP() + "/config"
    }
  }
  
  var requestType: HTTPMethod {
    return .get
  }
  
  var encoding: ParameterEncoding {
    return requestType == .get ? URLEncoding.default : JSONEncoding.default
  }
  
  var parameters: [String : Any]? {
    let parameters: [String: Any] = [:]
    return parameters
  }
  
  var requireAccessToken: Bool {
    return true
  }
}

class DomainOutput: APIOutputBase {
  var domain: Domain!
  
  init(_ domain: Domain) {
    super.init()
    self.domain = domain
  }
  
  required init?(map: Map) {
    super.init(map: map)
  }
  
  override func mapping(map: Map) {
    super.mapping(map: map)
  }
}
