//
//  APIInputBase.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation

protocol APIInputBase {
  var headers: Dictionary<String, String> { get }
  var urlString: String { get }
  var requestType: Method { get }
  var parameters: Dictionary<String, Any>? { get }
}


