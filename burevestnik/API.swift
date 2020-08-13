//
//  API.swift
//  burevestnik
//
//  Created by Marat on 14.08.2020.
//  Copyright © 2020 Marat. All rights reserved.
//

import Foundation

protocol API {

  func getTime() -> TimeInterval

  func foundPeer(peerID: String, time: TimeInterval)
  func lostPeer(peerID: String, time: TimeInterval)

  func sendToPeer(peerID: String, data: String)
  func didReceiveFromPeer(peerID: String, data: String)

}
