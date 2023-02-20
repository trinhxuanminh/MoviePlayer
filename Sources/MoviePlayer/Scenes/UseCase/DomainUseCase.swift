//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 18/02/2023.
//

import Foundation
import RxSwift

protocol DomainUseCaseProtocol {
  func config(completionHandler: @escaping (String?) -> Void)
}

class DomainUseCase: DomainUseCaseProtocol {
  private let domainRepository = DomainRepository()
  
  func config(completionHandler: @escaping (String?) -> Void) {
    return domainRepository.config(input: .config, completionHandler: completionHandler)
  }
}
