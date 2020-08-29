import Foundation

typealias NetworkMessage = String
typealias NetworkID = String
typealias NetworkTime = TimeInterval

//github.com/m4rr/burevestnik/blob/master/jsonrpc.md

protocol APIFuncs: class {

  /// 0
  func myID() -> NetworkID

  /// 4
  func sendToPeer(peerID: NetworkID, data: NetworkMessage)

}

extension APIFuncs {

  func myID() -> NetworkID {
    kThisDeviceName
  }

}

protocol APICallbacks: class {

  /// 1
  func tick(ts: NetworkTime)
  
  /// 2
  func foundPeer(peerID: NetworkID)
  /// 3
  func lostPeer(peerID: NetworkID)

  /// 5
  func didReceiveFromPeer(peerID: NetworkID, data: Data)

}

protocol MeshAPI: APIFuncs & APICallbacks {
  //
}

class APIMan: MeshAPI {

  func myID() -> NetworkID {
    localNetwork.myID()
  }

  var meshController: APICallbacks
  var localNetwork: APIFuncs

  init(meshController: APICallbacks, localNetwork: APIFuncs) {
    self.meshController = meshController
    self.localNetwork = localNetwork
  }

  // funcs

  func tick(ts: NetworkTime) {
    meshController.tick(ts: ts)
  }

  func sendToPeer(peerID: NetworkID, data: NetworkMessage) {
    localNetwork.sendToPeer(peerID: peerID, data: data)
  }

  // callbacks

  func foundPeer(peerID: NetworkID) {
    meshController.foundPeer(peerID: peerID)
  }

  func lostPeer(peerID: NetworkID) {
    meshController.lostPeer(peerID: peerID)
  }

  func didReceiveFromPeer(peerID: NetworkID, data: Data) {
    meshController.didReceiveFromPeer(peerID: peerID, data: data)
  }

}
