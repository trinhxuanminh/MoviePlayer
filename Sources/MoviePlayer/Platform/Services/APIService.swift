//
//  APIService.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation
import RxSwift
import RxCocoa

protocol APIServiceProtocol {
  func request(_ input: APIInputBase, completionHandler: @escaping (Dictionary<String, AnyObject>?) -> Void)
  func requestString(_ input: APIInputBase, completionHandler: @escaping (String?) -> Void)
}

class APIService: APIServiceProtocol {
  func request(_ input: APIInputBase, completionHandler: @escaping (Dictionary<String, AnyObject>?) -> Void) {
    guard let urlBase = URL(string: input.urlString) else {
      completionHandler(nil)
      return
    }
    var url = urlBase
    if let parameters = input.parameters {
      url = urlBase.appendingQueryParameters(parameters)
    }
    var request = URLRequest(url: url)
    request.httpMethod = input.requestType.rawValue
    request.appendingHeaders(input.headers)
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error in
      guard error == nil, let data = data else {
        print(error as Any)
        completionHandler(nil)
        return
      }
      do {
        let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
        completionHandler(json)
      } catch let error {
        print(error)
        completionHandler(nil)
      }
    })
    task.resume()
  }
  
  func requestString(_ input: APIInputBase, completionHandler: @escaping (String?) -> Void) {
    guard let urlBase = URL(string: input.urlString) else {
      completionHandler(nil)
      return
    }
    var url = urlBase
    if let parameters = input.parameters {
      url = urlBase.appendingQueryParameters(parameters)
    }
    var request = URLRequest(url: url)
    request.httpMethod = input.requestType.rawValue
    request.appendingHeaders(input.headers)
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error in
      guard error == nil, let data = data else {
        print(error as Any)
        completionHandler(nil)
        return
      }
      let json = String(data: data, encoding: .utf8)
      completionHandler(json)
    })
    task.resume()
  }
}
