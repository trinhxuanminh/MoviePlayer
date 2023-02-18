//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 18/02/2023.
//

import Foundation
import RxSwift

protocol DomainUseCaseProtocol {
  func config() -> Observable<String?>
}

class DomainUseCase: DomainUseCaseProtocol {
  private let domainRepository = DomainRepository()
  
  func config() -> Observable<String?> {
    return domainRepository.config(input: .config)
      .map { domainOutput in
        return domainOutput.domain.appDomain
      }
  }
}
