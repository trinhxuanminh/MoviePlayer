//
//  ListServerViewModel.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation
import RxSwift
import RxCocoa
import Differentiator
import Action

protocol ListServerViewModelProtocol {
    var selectAction: Action<IndexPath, Void>! { get }

    var stateLink: BehaviorRelay<String?> { get }
    var sections: BehaviorRelay<[CustomSectionModel]> { get }

    func setListServer(_ listServer: [ServerViewModelProtocol])
    func getServerName(index: Int) -> String
}

class ListServerViewModel: ListServerViewModelProtocol {

    private let disposeBag: DisposeBag

    // MARK: - Input
    private(set) var selectAction: Action<IndexPath, Void>!
    // MARK: - Output
    private(set) var stateLink = BehaviorRelay<String?>(value: nil)
    private(set) var sections = BehaviorRelay<[CustomSectionModel]>(value: [])

    private var listServer: [ServerViewModelProtocol]?

    init(disposeBag: DisposeBag) {
        self.disposeBag = disposeBag
        self.binding()
    }

    func setListServer(_ listServer: [ServerViewModelProtocol]) {
        self.listServer = listServer
        let section0 = CustomSectionModel(items: self.listServer ?? [])
        self.sections.accept([section0])
        if !listServer.isEmpty {
            self.bindStateLink(index: 0)
        }
    }

    func getServerName(index: Int) -> String {
        guard let listServer = listServer, index < listServer.count, let server = listServer[index].getServer() else {
            return "Unknown"
        }
        return server.name
    }

    private func binding() {
        self.selectAction = Action { [weak self] indexPath in
            guard let self = self else {
                return Observable.empty()
            }
            self.bindStateLink(index: indexPath.item)
            return Observable.empty()
        }
    }

    private func bindStateLink(index: Int) {
        guard let listServer = listServer, index < listServer.count, let server = listServer[index].getServer() else {
            return
        }
        self.stateLink.accept(server.link)
    }
}
