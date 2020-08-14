//
//  API.swift
//  burevestnik
//
//  Created by Marat on 14.08.2020.
//

import Foundation

//github.com/m4rr/burevestnik/blob/master/jsonrpc.md

protocol APIFuncs: class {

  /// 1
  func getTime()

  /// 4
  func sendToPeer()

}

protocol APICallbacks: class {

  /// 2
  func foundPeer()
  /// 3
  func lostPeer()

  /// 5
  func didReceiveFromPeer()

}

protocol API: APIFuncs & APICallbacks {

  var meshController: APICallbacks? { get set }
  var localNetwork: APIFuncs? { get set }

}

class APIMan: API {

  weak var meshController: APICallbacks?
  weak var localNetwork: APIFuncs?

  init(meshController: APICallbacks, localNetwork: APIFuncs) {
    self.meshController = meshController
    self.localNetwork = localNetwork
  }

  // funcs

  func getTime() {
    localNetwork?.getTime()
  }

  func sendToPeer() {
    localNetwork?.sendToPeer()
  }

  // callbacks

  func foundPeer() {
    meshController?.foundPeer()
  }

  func lostPeer() {
    meshController?.lostPeer()
  }

  func didReceiveFromPeer() {
    meshController?.didReceiveFromPeer()
  }

}
