//
//  API.swift
//  burevestnik
//
//  Created by Marat Saytakov on 14.08.2020.
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
