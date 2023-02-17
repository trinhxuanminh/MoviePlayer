//
//  APIOutputBase.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import ObjectMapper
import Alamofire

class APIOutputBase: Mappable {
  init() {}
  
  required init?(map: Map) {}
  
  func mapping(map: Map) {}
}
