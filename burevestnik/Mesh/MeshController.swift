//
//  MeshController.swift
//  burevestnik
//
//  Created by Marat on 14.08.2020.
//

import Foundation

class MeshController: APICallbacks {

  func foundPeer(peerID: String, date: Date) {

  }

  func lostPeer(peerID: String, date: Date) {

  }

  func didReceiveFromPeer(peerID: String, data: Data) {

  }

  var reloadHandler: () -> Void

  var storage = [BroadMessage]()

//  weak var api: APIFuncs?

  init(reloadHandler: @escaping () -> Void) {

    self.reloadHandler = reloadHandler

  }

}
