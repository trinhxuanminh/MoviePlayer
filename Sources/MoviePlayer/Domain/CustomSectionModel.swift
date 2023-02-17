//
//  CustomSectionModel.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import RxDataSources

struct CustomSectionModel {
  var header: String?
  var footer: String?
  var items: [Any?]
}

extension CustomSectionModel: SectionModelType {
  typealias Item = Any?
  
  init(original: CustomSectionModel, items: [Any?]) {
    self = original
    self.items = items
  }
}
