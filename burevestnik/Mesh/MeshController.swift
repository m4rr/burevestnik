//
//  MeshController.swift
//  burevestnik
//
//  Created by Marat on 14.08.2020.
//

import Foundation

class MeshController {

  var reloadHandler: AnyVoid?

  var storage = [BroadMessage]()

  weak var api: APIFuncs?

  init(reloadHandler: AnyVoid?) {

    self.reloadHandler = reloadHandler

  }

  func notifySomeone() {
    #warning("stub")

    api?.sendToPeer(peerID: "", data: Data())
  }

}

extension MeshController: APICallbacks {

  func foundPeer(peerID: String, date: Date) {

  }

  func lostPeer(peerID: String, date: Date) {

  }

  func didReceiveFromPeer(peerID: String, data: Data) {

  }

}
