//
//  APIExtensions.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation

enum Method: String {
  case get = "GET"
}

extension URL {
  /**
   Creates a new URL by adding the given query parameters.
   @param parametersDictionary The query parameter dictionary to add.
   @return A new URL.
   */
  func appendingQueryParameters(_ parametersDictionary: Dictionary<String, Any>) -> URL {
    let URLString = String(format: "%@?%@", absoluteString, parametersDictionary.queryParameters)
    return URL(string: URLString)!
  }
}

protocol URLQueryParameterStringConvertible {
  var queryParameters: String {get}
}

extension Dictionary: URLQueryParameterStringConvertible {
  /**
   This computed property returns a query parameters string from the given NSDictionary. For
   example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
   string will be @"day=Tuesday&month=January".
   @return The computed parameters string.
   */
  var queryParameters: String {
    var parts: [String] = []
    for (key, value) in self {
      let part = String(format: "%@=%@",
                        String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                        String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
      parts.append(part as String)
    }
    return parts.joined(separator: "&")
  }
}

extension URLRequest {
  mutating func appendingHeaders(_ headersDictionary: Dictionary<String, String>) {
    for (key, value) in headersDictionary {
      addValue(value, forHTTPHeaderField: key)
    }
  }
}
