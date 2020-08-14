//
//  MeshController.swift
//  burevestnik
//
//  Created by Marat on 14.08.2020.
//

import Foundation

class MeshController: APICallbacks {

  var reloadHandler: () -> Void

  var storage = [BroadMessage]()

//  weak var api: APIFuncs?

  init(reloadHandler: @escaping () -> Void) {

    self.reloadHandler = reloadHandler

  }

  func foundPeer() {

  }

  func lostPeer() {

  }

  func didReceiveFromPeer() {

  }

}
