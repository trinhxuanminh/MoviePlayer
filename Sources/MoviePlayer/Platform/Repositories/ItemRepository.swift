//
//  ItemRepository.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation
import RxSwift
import RxCocoa

protocol ItemRepositoryProtocol {
  func loadServer(input: ItemServerInput) -> Observable<ItemServerOutput>
}

class ItemRepository: APIService, ItemRepositoryProtocol {
  func loadServer(input: ItemServerInput) -> Observable<ItemServerOutput> {
    return requestString(input)
      .observe(on: MainScheduler.instance)
      .map({ codingValue in
        return ItemServerOutput(html: codingValue)
      })
      .share(replay: 1, scope: .whileConnected)
  }
}
