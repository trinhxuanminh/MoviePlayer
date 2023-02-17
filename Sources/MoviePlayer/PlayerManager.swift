//
//  PlayerManager.swift
//  
//
//  Created by Trịnh Xuân Minh on 17/02/2023.
//

import Foundation

public struct PlayerManager {
  public static var shared = PlayerManager()
  
  var movieDomain: String!
  var tvDomain: String!
  
  public func showMovie(domain: String,
                        name: String,
                        tmdbId: Int,
                        limitHandler: (() -> Void)?
  ) {}
  
  public func showTV(domain: String,
                     name: String,
                     tmdbId: Int,
                     season: Int,
                     episode: Int,
                     limitHandler: (() -> Void)?
  ) {}
}
