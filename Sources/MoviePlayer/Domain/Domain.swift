//
//  Domain.swift
//  
//
//  Created by Trịnh Xuân Minh on 18/02/2023.
//

import ObjectMapper

struct Domain: Mappable {
  var createdAt: String?
  var id: String?
  var appDomain: String?
  
  init() {
    
  }
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    self.id <- map["id"]
    self.createdAt <- map["createdAt"]
    self.appDomain <- map["appDomain"]
  }
}
