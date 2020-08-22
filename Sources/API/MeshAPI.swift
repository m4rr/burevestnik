import Foundation

//github.com/m4rr/burevestnik/blob/master/jsonrpc.md

typealias NetworkMessage = String
typealias NetworkID = String
typealias NetworkTime = TimeInterval

protocol APIFuncs: class {

  /// 0
  func myID() -> NetworkID

  /// 4
  func sendToPeer(peerID: NetworkID, data: NetworkMessage)

}

protocol APICallbacks: class {

  /// 1
  func tick(ts: Date)
  
  /// 2
  func foundPeer(peerID: String)
  /// 3
  func lostPeer(peerID: String)

  /// 5
  func didReceiveFromPeer(peerID: String, data: Data)

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

  func tick(ts: Date) {
    meshController.tick(ts: ts)
  }

  func sendToPeer(peerID: NetworkID, data: NetworkMessage) {
    localNetwork.sendToPeer(peerID: peerID, data: data)
  }

  // callbacks

  func foundPeer(peerID: String) {
    meshController.foundPeer(peerID: peerID)
  }

  func lostPeer(peerID: String) {
    meshController.lostPeer(peerID: peerID)
  }

  func didReceiveFromPeer(peerID: String, data: Data) {
    meshController.didReceiveFromPeer(peerID: peerID, data: data)
  }

}
