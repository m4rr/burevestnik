//
//  MeshController.swift
//  burevestnik
//
//  Created by Marat on 14.08.2020.
//

import Foundation

class MeshController: NSObject, UiHandler {

  var reloadHandler: AnyVoid = { }

  func broadcastMessage(_ text: String) {
    peers.forEach { (peerID) in
      if let data = text.data {
        api?.sendToPeer(peerID: peerID, data: data)
      }
    }
  }

  var messages = [BroadMessage]()
  var peers = [String]()

  weak var api: APIFuncs?

  func notifySomeone() {
    api?.sendToPeer(peerID: "", data: Data())
    #warning("stub")
  }

}

extension MeshController: APICallbacks {

  func foundPeer(peerID: String, date: Date) {

  }

  func lostPeer(peerID: String, date: Date) {

  }

  func didReceiveFromPeer(peerID: String, data: Data) {
    reloadHandler()
  }

}
