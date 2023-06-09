//
//  ServerBody.swift
//  
//
//  Created by Trịnh Xuân Minh on 09/06/2023.
//

import Foundation

struct ServerBody: Codable {
  let name: String
  let tmdbId: Int
  let imdbId: String?
  var html: Bool = true
  let season: Int?
  let episode: Int?
}
