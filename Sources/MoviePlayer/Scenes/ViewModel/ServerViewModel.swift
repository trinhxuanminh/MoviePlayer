////
////  ServerViewModel.swift
////  
////
////  Created by Trịnh Xuân Minh on 17/02/2023.
////
//
//import Foundation
//import RxSwift
//import RxCocoa
//
//protocol ServerViewModelProtocol {
//  var name: BehaviorRelay<String?> { get }
//  var link: BehaviorRelay<String?> { get }
//  
//  func setServer(_ server: Server)
//  func getServer() -> Server?
//}
//
//class ServerViewModel: ServerViewModelProtocol {
//  private let disposeBag = DisposeBag()
//  
//  // MARK: - Input
//  
//  // MARK: - Output
//  private(set) var name = BehaviorRelay<String?>(value: nil)
//  private(set) var link = BehaviorRelay<String?>(value: nil)
//  
//  private var server = BehaviorRelay<Server?>(value: nil)
//  
//  init() {
//    binding()
//  }
//  
//  func setServer(_ server: Server) {
//    self.server.accept(server)
//  }
//  
//  func getServer() -> Server? {
//    return server.value
//  }
//  
//  private func binding() {
//    server.bind { [weak self] server in
//      guard let self = self, let server = server else {
//        return
//      }
//      self.bindName(name: server.name)
//      self.bindLink(link: server.link)
//    }.disposed(by: disposeBag)
//  }
//  
//  private func bindName(name: String?) {
//    if let name = name {
//      self.name.accept(name)
//    }
//  }
//  
//  private func bindLink(link: String?) {
//    if let link = link {
//      self.link.accept(link)
//    }
//  }
//}
