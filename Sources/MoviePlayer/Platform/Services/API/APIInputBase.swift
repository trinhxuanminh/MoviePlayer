//
//  APIInputBase.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation
import ObjectMapper
import Alamofire

protocol APIInputBase {
  var headers: HTTPHeaders { get }
  var urlString: String { get }
  var requestType: HTTPMethod { get }
  var encoding: ParameterEncoding { get }
  var parameters: [String: Any]? { get }
  var requireAccessToken: Bool { get }
}
