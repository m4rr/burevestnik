//
//  API.swift
//  burevestnik
//
//  Created by Marat on 14.08.2020.
//  Copyright © 2020 Marat. All rights reserved.
//

import Foundation

protocol API: class {

  func getTime() -> TimeInterval

  func foundPeer(peerID: String, time: TimeInterval)
  func lostPeer(peerID: String, time: TimeInterval)

  func sendToPeer(peerID: String, data: String)
  func didReceiveFromPeer(peerID: String, data: String)

}

extension BtMan: API {

  func getTime() -> TimeInterval {
    return Date().timeIntervalSince1970
  }

  func foundPeer(peerID: String, time: TimeInterval) {
    
  }

  func lostPeer(peerID: String, time: TimeInterval) {

  }

  func sendToPeer(peerID: String, data: String) {
    sessionSend(to: peerID, data: data)
  }

  func didReceiveFromPeer(peerID: String, data: String) {

  }

}
