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
  func getTime() -> Date

  /// 4
  func sendToPeer(peerID: String, data: Data)

}

protocol APICallbacks: class {

  /// 2
  func foundPeer(peerID: String, date: Date)
  /// 3
  func lostPeer(peerID: String, date: Date)

  /// 5
  func didReceiveFromPeer(peerID: String, data: Data)

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

  func getTime() -> Date {
    return localNetwork!.getTime()
  }

  func sendToPeer(peerID: String, data: Data) {
    localNetwork?.sendToPeer(peerID: peerID, data: data)
  }

  // callbacks

  func foundPeer(peerID: String, date: Date) {
    meshController?.foundPeer(peerID: peerID, date: date)
  }

  func lostPeer(peerID: String, date: Date) {
    meshController?.lostPeer(peerID: peerID, date: date)
  }

  func didReceiveFromPeer(peerID: String, data: Data) {
    meshController?.didReceiveFromPeer(peerID: peerID, data: data)
  }

}
