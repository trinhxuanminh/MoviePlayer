//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 18/02/2023.
//

import Foundation

enum DomainInput {
  case config
}

extension DomainInput: APIInputBase {
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
    return nil
  }
  
  var urlString: String {
    switch self {
    case .config:
      return "http://" + PlayerManager.shared.getIP() + "/config"
    }
  }
}
