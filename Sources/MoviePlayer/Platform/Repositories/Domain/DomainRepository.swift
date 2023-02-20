//
//  File 2.swift
//  
//
//  Created by Trịnh Xuân Minh on 18/02/2023.
//

import Foundation
import RxSwift
import RxCocoa

protocol DomainRepositoryProtocol {
  func config(input: DomainInput, completionHandler: @escaping (String?) -> Void)
}

class DomainRepository: APIService, DomainRepositoryProtocol {
  func config(input: DomainInput, completionHandler: @escaping (String?) -> Void) {
    request(input) { output in
      guard let output = output, let appDomain = output["appDomain"] as? String else {
        completionHandler(nil)
        return
      }
      completionHandler(appDomain)
    }
  }
}
