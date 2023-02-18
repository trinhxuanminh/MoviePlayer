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
  func config(input: DomainInput) -> Observable<DomainOutput>
}

class DomainRepository: APIService, DomainRepositoryProtocol {
  func config(input: DomainInput) -> Observable<DomainOutput> {
    return self.request(input)
      .observe(on: MainScheduler.instance)
      .map({ domain in
        return DomainOutput(domain)
      })
      .share(replay: 1, scope: .whileConnected)
  }
}
